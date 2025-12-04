#------------------------------------------------------------------------------
# Cloud Migration - Production Environment
#------------------------------------------------------------------------------
# AWS landing zone for on-premises to cloud migration:
# - Multi-AZ VPC with Site-to-Site VPN and Transit Gateway connectivity
# - ALB + EC2 ASG for migrated applications
# - RDS Multi-AZ for migrated databases
# - S3 with cross-region replication for DR
# - RTO: 4 hours, RPO: 1 hour
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Locals
#------------------------------------------------------------------------------
locals {
  environment = basename(path.module)
  name_prefix = "${var.solution.abbr}-${local.environment}"

  project = {
    name        = var.solution.abbr
    environment = local.environment
  }

  common_tags = {
    Solution     = var.solution.name
    SolutionAbbr = var.solution.abbr
    Environment  = local.environment
    Provider     = var.solution.provider_name
    Category     = var.solution.category_name
    Region       = var.aws.region
    ManagedBy    = "terraform"
    CostCenter   = var.ownership.cost_center
    Owner        = var.ownership.owner_email
    ProjectCode  = var.ownership.project_code
  }
}

#------------------------------------------------------------------------------
# Data Sources
#------------------------------------------------------------------------------
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

#===============================================================================
# FOUNDATION - Core infrastructure
#===============================================================================
#------------------------------------------------------------------------------
# Security (KMS + WAF + Security Groups)
#------------------------------------------------------------------------------
module "security" {
  source = "../../modules/solution/security"

  project = local.project
  security = {
    kms_deletion_window_days = var.security.kms_deletion_window_days
    enable_kms_key_rotation  = var.security.enable_kms_key_rotation
    enable_waf               = var.security.enable_waf
    waf_rate_limit           = var.security.waf_rate_limit
  }
  network = {
    vpc_id   = module.core.vpc_id
    app_port = var.compute.app_port
  }
  common_tags = local.common_tags

  depends_on = [module.core]
}

#------------------------------------------------------------------------------
# Core Infrastructure (VPC + ALB + ASG + Hybrid Connectivity)
#------------------------------------------------------------------------------
module "core" {
  source = "../../modules/solution/core"

  project = local.project
  network = {
    vpc_cidr                = var.network.vpc_cidr
    enable_nat_gateway      = var.network.enable_nat_gateway
    enable_flow_logs        = var.network.enable_flow_logs
    public_subnet_cidrs     = var.network.public_subnet_cidrs
    private_subnet_cidrs    = var.network.private_subnet_cidrs
    database_subnet_cidrs   = var.network.database_subnet_cidrs
    enable_site_to_site_vpn = var.network.enable_site_to_site_vpn
    on_prem_cidr            = var.network.on_prem_cidr
  }
  compute = {
    instance_type              = var.compute.instance_type
    ami_id                     = var.compute.ami_id
    asg_min_size               = var.compute.asg_min_size
    asg_max_size               = var.compute.asg_max_size
    asg_desired_capacity       = var.compute.asg_desired_capacity
    root_volume_size           = var.compute.root_volume_size
    data_volume_size           = var.compute.data_volume_size
    app_port                   = var.compute.app_port
    health_check_path          = var.compute.health_check_path
    ssl_certificate_arn        = var.compute.ssl_certificate_arn
    enable_deletion_protection = var.compute.enable_deletion_protection
  }
  security = {
    alb_security_group_id = module.security.alb_security_group_id
    app_security_group_id = module.security.app_security_group_id
    kms_key_arn           = module.security.kms_key_arn
  }
  common_tags = local.common_tags
}

#===============================================================================
# CORE SOLUTION - Application and data tiers
#===============================================================================
#------------------------------------------------------------------------------
# Database (RDS Multi-AZ)
#------------------------------------------------------------------------------
module "database" {
  source = "../../modules/solution/database"

  project = local.project
  database = {
    engine                      = var.database.engine
    engine_version              = var.database.engine_version
    database_name               = var.database.database_name
    master_username             = var.database.master_username
    master_password             = var.database.master_password
    instance_class              = var.database.instance_class
    multi_az                    = var.database.multi_az
    allocated_storage           = var.database.allocated_storage
    max_allocated_storage       = var.database.max_allocated_storage
    backup_retention_days       = var.database.backup_retention_days
    backup_window               = var.database.backup_window
    maintenance_window          = var.database.maintenance_window
    enable_deletion_protection  = var.database.enable_deletion_protection
    skip_final_snapshot         = var.database.skip_final_snapshot
    enable_performance_insights = var.database.enable_performance_insights
    enable_read_replica         = var.database.enable_read_replica
  }
  network = {
    database_subnet_ids = module.core.database_subnet_ids
  }
  security = {
    db_security_group_id = module.security.db_security_group_id
    kms_key_arn          = module.security.kms_key_arn
  }
  common_tags = local.common_tags

  depends_on = [module.security, module.core]
}

#------------------------------------------------------------------------------
# Storage (S3 with Cross-Region Replication)
#------------------------------------------------------------------------------
module "storage" {
  source = "../../modules/solution/storage"

  project = local.project
  storage = {
    enable_versioning                  = var.storage.enable_versioning
    transition_to_ia_days              = var.storage.transition_to_ia_days
    transition_to_glacier_days         = var.storage.transition_to_glacier_days
    noncurrent_version_expiration_days = var.storage.noncurrent_version_expiration_days
    enable_replication                 = var.storage.enable_replication
    dr_region                          = var.aws.dr_region
  }
  security = {
    kms_key_arn = module.security.kms_key_arn
  }
  common_tags = local.common_tags

  depends_on = [module.security]
}

#===============================================================================
# OPERATIONS - Monitoring and DR
#===============================================================================
#------------------------------------------------------------------------------
# Monitoring (CloudWatch Dashboard + Alarms)
#------------------------------------------------------------------------------
module "monitoring" {
  source = "../../modules/solution/monitoring"

  project = local.project
  aws = {
    region = var.aws.region
  }
  resources = {
    alb_arn           = module.core.alb_arn
    target_group_arn  = module.core.target_group_arn
    asg_name          = module.core.asg_name
    rds_instance_id   = module.database.instance_id
    s3_bucket_id      = module.storage.bucket_id
  }
  monitoring = {
    alert_email               = var.monitoring.alert_email
    ec2_cpu_threshold         = var.monitoring.ec2_cpu_threshold
    rds_cpu_threshold         = var.monitoring.rds_cpu_threshold
    rds_connections_threshold = var.monitoring.rds_connections_threshold
    alb_5xx_threshold         = var.monitoring.alb_5xx_threshold
    log_retention_days        = var.monitoring.log_retention_days
  }
  security = {
    kms_key_id = module.security.kms_key_id
  }
  common_tags = local.common_tags

  depends_on = [module.core, module.database, module.storage]
}

#===============================================================================
# INTEGRATIONS - Cross-module connections
#===============================================================================
#------------------------------------------------------------------------------
# WAF Web ACL Association
#------------------------------------------------------------------------------
resource "aws_wafv2_web_acl_association" "alb" {
  count = var.security.enable_waf ? 1 : 0

  resource_arn = module.core.alb_arn
  web_acl_arn  = module.security.waf_web_acl_arn

  depends_on = [module.security, module.core]
}

#------------------------------------------------------------------------------
# RDS CloudWatch Alarms (monitoring → database)
#------------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "rds_cpu" {
  alarm_name          = "${local.name_prefix}-rds-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = var.monitoring.rds_cpu_threshold
  alarm_description   = "RDS CPU utilization is too high"
  alarm_actions       = [module.monitoring.sns_topic_arn]
  ok_actions          = [module.monitoring.sns_topic_arn]

  dimensions = {
    DBInstanceIdentifier = module.database.instance_id
  }

  tags = local.common_tags

  depends_on = [module.database, module.monitoring]
}

resource "aws_cloudwatch_metric_alarm" "rds_connections" {
  alarm_name          = "${local.name_prefix}-rds-connections-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = var.monitoring.rds_connections_threshold
  alarm_description   = "RDS connection count is too high"
  alarm_actions       = [module.monitoring.sns_topic_arn]
  ok_actions          = [module.monitoring.sns_topic_arn]

  dimensions = {
    DBInstanceIdentifier = module.database.instance_id
  }

  tags = local.common_tags

  depends_on = [module.database, module.monitoring]
}
