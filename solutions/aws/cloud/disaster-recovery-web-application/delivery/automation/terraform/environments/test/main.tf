#------------------------------------------------------------------------------
# DR Web Application - Test Environment
#------------------------------------------------------------------------------
# Minimal test environment for validation (no DR features):
# - Single-AZ for cost savings
# - Reduced instance sizes
# - No cross-region replication
# - No WAF or GuardDuty
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
# FOUNDATION
#===============================================================================
#------------------------------------------------------------------------------
# Security (KMS + Security Groups - No WAF)
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
# Core Infrastructure (VPC + ALB + ASG)
#------------------------------------------------------------------------------
module "core" {
  source = "../../modules/solution/core"

  project = local.project
  network = {
    vpc_cidr              = var.network.vpc_cidr
    enable_nat_gateway    = var.network.enable_nat_gateway
    enable_flow_logs      = var.network.enable_flow_logs
    public_subnet_cidrs   = var.network.public_subnet_cidrs
    private_subnet_cidrs  = var.network.private_subnet_cidrs
    database_subnet_cidrs = var.network.database_subnet_cidrs
  }
  compute = {
    instance_type              = var.compute.instance_type
    ami_id                     = var.compute.ami_id
    asg_min_size               = var.compute.asg_min_size
    asg_max_size               = var.compute.asg_max_size
    asg_desired_capacity       = var.compute.asg_desired_capacity
    root_volume_size           = var.compute.root_volume_size
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
# CORE SOLUTION
#===============================================================================
#------------------------------------------------------------------------------
# Database (Aurora - Single Instance, No Global)
#------------------------------------------------------------------------------
module "database" {
  source = "../../modules/solution/database"

  project = local.project
  database = {
    is_primary_region           = var.database.is_primary_region
    engine_version              = var.database.engine_version
    database_name               = var.database.database_name
    master_username             = var.database.master_username
    master_password             = var.database.master_password
    instance_class              = var.database.instance_class
    instance_count              = var.database.instance_count
    backup_retention_days       = var.database.backup_retention_days
    backup_window               = var.database.backup_window
    maintenance_window          = var.database.maintenance_window
    enable_deletion_protection  = var.database.enable_deletion_protection
    skip_final_snapshot         = var.database.skip_final_snapshot
    monitoring_interval         = var.database.monitoring_interval
    enable_performance_insights = var.database.enable_performance_insights
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
# Storage (S3 - No Replication)
#------------------------------------------------------------------------------
module "storage" {
  source = "../../modules/solution/storage"

  project = local.project
  storage = {
    enable_versioning                  = var.storage.enable_versioning
    transition_to_ia_days              = var.storage.transition_to_ia_days
    transition_to_glacier_days         = var.storage.transition_to_glacier_days
    noncurrent_version_expiration_days = var.storage.noncurrent_version_expiration_days
    enable_replication                 = false  # No DR for test
  }
  security = {
    kms_key_arn = module.security.kms_key_arn
  }
  common_tags = local.common_tags

  depends_on = [module.security]
}
