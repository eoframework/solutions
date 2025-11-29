# Production Environment - Full Deployment
#
# Composes: core + database + cache + security + monitoring
#
# This is a full production deployment with:
# - VPC, ALB, ASG (core)
# - RDS with Multi-AZ (database)
# - ElastiCache Redis cluster (cache)
# - WAF, GuardDuty, CloudTrail (security)
# - CloudWatch Dashboard, X-Ray (monitoring)
#
# See providers.tf for Terraform/AWS provider configuration
# See README.md for prerequisites and setup instructions

#------------------------------------------------------------------------------
# Naming Standards & Common Tags
#------------------------------------------------------------------------------
# All resources use consistent naming: {solution_abbr}-{environment}-{resource}
# Environment is auto-discovered from folder name or can be overridden
#------------------------------------------------------------------------------

locals {
  # Auto-discover environment from folder name (prod, test, dr)
  auto_environment = basename(path.module)

  # Use explicit variable if set, otherwise auto-discover
  environment = var.environment != "" ? var.environment : local.auto_environment

  # Environment display names for human-readable outputs
  env_display_name = {
    prod = "Production"
    test = "Test"
    dr   = "Disaster Recovery"
  }

  # Standardized naming prefix: {solution_abbr}-{environment}
  # Example: vxr-prod, sfi-test, pci-dr
  name_prefix = "${var.solution_abbr}-${local.environment}"

  # Common tags applied to ALL resources via provider default_tags
  common_tags = {
    Solution     = var.solution_name
    SolutionAbbr = var.solution_abbr
    Environment  = local.environment
    EnvDisplay   = lookup(local.env_display_name, local.environment, local.environment)
    Provider     = var.provider_name
    Category     = var.category_name
    Region       = var.aws_region
    ManagedBy    = "terraform"
    CostCenter   = var.cost_center
    Owner        = var.owner_email
    ProjectCode  = var.project_code
  }

  # Merge with any additional custom tags
  all_tags = merge(local.common_tags, var.additional_tags)
}

#------------------------------------------------------------------------------
# Core Infrastructure (Required)
#------------------------------------------------------------------------------

module "core" {
  source = "../../modules/solution/core"

  # Naming (using standardized prefix from locals)
  name_prefix     = local.name_prefix
  project_name    = var.solution_name
  environment     = local.environment
  additional_tags = local.all_tags

  # Networking
  vpc_cidr              = var.vpc_cidr
  public_subnet_cidrs   = var.public_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
  database_subnet_cidrs = var.database_subnet_cidrs
  enable_dns_hostnames  = var.enable_dns_hostnames
  enable_dns_support    = var.enable_dns_support
  enable_nat_gateway    = var.enable_nat_gateway
  single_nat_gateway    = var.single_nat_gateway
  enable_flow_logs      = var.enable_flow_logs
  flow_log_retention_days = var.flow_log_retention_days

  # Security
  allowed_https_cidrs     = var.allowed_https_cidrs
  allowed_http_cidrs      = var.allowed_http_cidrs
  allowed_ssh_cidrs       = var.allowed_ssh_cidrs
  enable_ssh_access       = var.enable_ssh_access
  enable_kms_encryption   = var.enable_kms_encryption
  kms_key_arn             = module.security.kms_key_arn
  enable_instance_profile = var.enable_instance_profile
  enable_ssm_access       = var.enable_ssm_access
  require_imdsv2          = var.require_imdsv2
  metadata_hop_limit      = var.metadata_hop_limit

  # Compute
  instance_type              = var.instance_type
  use_latest_ami             = var.use_latest_ami
  root_volume_size           = var.root_volume_size
  root_volume_type           = var.root_volume_type
  root_volume_iops           = var.root_volume_iops
  root_volume_throughput     = var.root_volume_throughput
  enable_detailed_monitoring = var.enable_detailed_monitoring

  # Auto Scaling
  enable_auto_scaling       = var.enable_auto_scaling
  asg_min_size              = var.asg_min_size
  asg_max_size              = var.asg_max_size
  asg_desired_capacity      = var.asg_desired_capacity
  health_check_grace_period = var.health_check_grace_period
  scale_up_threshold        = var.scale_up_threshold
  scale_down_threshold      = var.scale_down_threshold

  # Load Balancer
  enable_alb                    = var.enable_alb
  alb_internal                  = var.alb_internal
  enable_lb_deletion_protection = var.enable_lb_deletion_protection
  acm_certificate_arn           = var.acm_certificate_arn
  health_check_path             = var.health_check_path
  health_check_interval         = var.health_check_interval
  health_check_timeout          = var.health_check_timeout
  healthy_threshold             = var.healthy_threshold
  unhealthy_threshold           = var.unhealthy_threshold

  # Application
  app_port = var.app_port
}

#------------------------------------------------------------------------------
# Security (WAF, GuardDuty, CloudTrail, KMS)
#------------------------------------------------------------------------------

module "security" {
  source = "../../modules/solution/security"

  name_prefix = local.name_prefix
  common_tags = local.all_tags
  alb_arn     = module.core.alb_arn

  # KMS
  enable_kms_key      = var.enable_kms_encryption
  kms_deletion_window = var.kms_deletion_window
  enable_key_rotation = var.enable_key_rotation

  # WAF
  enable_waf     = var.enable_waf
  waf_rate_limit = var.waf_rate_limit

  # GuardDuty
  enable_guardduty = var.enable_guardduty

  # CloudTrail
  enable_cloudtrail         = var.enable_cloudtrail
  cloudtrail_retention_days = var.cloudtrail_retention_days
}

#------------------------------------------------------------------------------
# Database (RDS)
#------------------------------------------------------------------------------

module "database" {
  source = "../../modules/solution/database"

  name_prefix          = local.name_prefix
  common_tags          = local.all_tags
  environment          = local.environment
  db_subnet_group_name = module.core.db_subnet_group_name
  security_group_ids   = [module.core.database_security_group_id]
  kms_key_arn          = module.security.kms_key_arn

  # Engine
  db_engine         = var.db_engine
  db_engine_version = var.db_engine_version
  db_instance_class = var.db_instance_class

  # Storage
  db_allocated_storage     = var.db_allocated_storage
  db_max_allocated_storage = var.db_max_allocated_storage
  db_storage_encrypted     = var.db_storage_encrypted

  # Database
  db_name     = var.db_name
  db_username = var.db_username
  db_password = var.db_password

  # High Availability
  db_multi_az = var.db_multi_az

  # Backup
  db_backup_retention   = var.db_backup_retention
  db_backup_window      = var.db_backup_window
  db_maintenance_window = var.db_maintenance_window

  # Monitoring
  db_performance_insights = var.db_performance_insights

  # Protection
  db_deletion_protection = var.db_deletion_protection

  # Alarms
  enable_alarms       = true
  alarm_sns_topic_arn = module.monitoring.sns_topic_arn
}

#------------------------------------------------------------------------------
# Cache (ElastiCache Redis)
#------------------------------------------------------------------------------

module "cache" {
  source = "../../modules/solution/cache"

  name_prefix                   = local.name_prefix
  common_tags                   = local.all_tags
  elasticache_subnet_group_name = module.core.elasticache_subnet_group_name
  security_group_ids            = [module.core.cache_security_group_id]
  kms_key_arn                   = module.security.kms_key_arn

  # Engine
  cache_engine_version = var.cache_engine_version
  cache_node_type      = var.cache_node_type
  cache_num_nodes      = var.cache_num_nodes

  # High Availability
  cache_automatic_failover = var.cache_automatic_failover

  # Encryption
  cache_at_rest_encryption = var.cache_at_rest_encryption
  cache_transit_encryption = var.cache_transit_encryption

  # Maintenance
  cache_snapshot_retention = var.cache_snapshot_retention
  cache_snapshot_window    = var.cache_snapshot_window

  # Alarms
  enable_alarms       = true
  alarm_sns_topic_arn = module.monitoring.sns_topic_arn
}

#------------------------------------------------------------------------------
# Monitoring (CloudWatch, X-Ray)
#------------------------------------------------------------------------------

module "monitoring" {
  source = "../../modules/solution/monitoring"

  name_prefix  = local.name_prefix
  common_tags  = local.all_tags
  project_name = var.solution_name
  environment  = local.environment
  kms_key_arn  = module.security.kms_key_arn

  # Resource references
  alb_arn          = module.core.alb_arn
  asg_name         = module.core.asg_name
  rds_identifier   = module.database.rds_identifier
  cache_cluster_id = module.cache.cache_replication_group_id

  # Logging
  log_retention_days        = var.log_retention_days
  enable_container_insights = var.enable_container_insights

  # Dashboard
  enable_dashboard = var.enable_dashboard

  # Alerting
  alarm_email = var.alarm_email

  # X-Ray
  enable_xray_tracing = var.enable_xray_tracing
}

#------------------------------------------------------------------------------
# Well-Architected Framework: Operational Excellence (AWS Config)
#------------------------------------------------------------------------------

module "config_rules" {
  source = "../../modules/aws/well-architected/operational-excellence/config-rules"
  count  = var.enable_config_rules ? 1 : 0

  name_prefix = local.name_prefix
  common_tags = local.all_tags

  # Config Recorder
  enable_config_recorder = var.enable_config_recorder

  # S3 for Config delivery
  config_bucket_name        = var.config_bucket_name != "" ? var.config_bucket_name : "${local.name_prefix}-config"
  config_bucket_prefix      = "config"
  config_retention_days     = var.config_retention_days
  enable_bucket_versioning  = true
  enable_bucket_encryption  = true

  # Rule categories
  enable_security_rules     = true
  enable_reliability_rules  = true
  enable_operational_rules  = true
  enable_cost_rules         = true

  # Notifications
  sns_topic_arn = module.monitoring.sns_topic_arn
}

#------------------------------------------------------------------------------
# Well-Architected Framework: Security (Enhanced GuardDuty)
#------------------------------------------------------------------------------

module "guardduty_enhanced" {
  source = "../../modules/aws/well-architected/security/guardduty"
  count  = var.enable_guardduty_enhanced ? 1 : 0

  name_prefix = local.name_prefix
  common_tags = local.all_tags

  # Protection features
  enable_s3_protection      = true
  enable_eks_protection     = var.enable_eks_protection
  enable_malware_protection = var.enable_malware_protection

  # Findings export
  enable_findings_export = true
  findings_bucket_name   = var.guardduty_findings_bucket != "" ? var.guardduty_findings_bucket : "${local.name_prefix}-guardduty-findings"
  kms_key_arn            = module.security.kms_key_arn

  # Alerting
  enable_sns_notifications = true
  sns_topic_arn            = module.monitoring.sns_topic_arn
  high_severity_threshold  = var.guardduty_severity_threshold
}

#------------------------------------------------------------------------------
# Well-Architected Framework: Reliability (AWS Backup)
#------------------------------------------------------------------------------

module "backup_plans" {
  source = "../../modules/aws/well-architected/reliability/backup-plans"
  count  = var.enable_backup_plans ? 1 : 0

  name_prefix = local.name_prefix
  common_tags = local.all_tags

  # Encryption
  kms_key_arn    = module.security.kms_key_arn
  dr_kms_key_arn = var.dr_kms_key_arn

  # Daily backup
  daily_backup_schedule = var.backup_daily_schedule
  daily_retention_days  = var.backup_daily_retention

  # Weekly backup
  enable_weekly_backup   = true
  weekly_backup_schedule = var.backup_weekly_schedule
  weekly_retention_days  = var.backup_weekly_retention

  # Monthly backup
  enable_monthly_backup     = true
  monthly_backup_schedule   = var.backup_monthly_schedule
  monthly_retention_days    = var.backup_monthly_retention
  monthly_cold_storage_days = var.backup_cold_storage_days

  # Cross-region DR copy
  enable_cross_region_copy = var.enable_backup_cross_region
  dr_retention_days        = var.backup_dr_retention

  # Resource selection
  enable_tag_based_selection = true
  backup_tag_key             = "Backup"
  backup_tag_value           = "true"
  resource_arns              = var.backup_resource_arns

  # Additional features
  enable_continuous_backup = var.enable_continuous_backup
  enable_windows_vss       = var.enable_windows_vss

  # Compliance (vault lock)
  enable_vault_lock         = var.enable_backup_vault_lock
  vault_lock_min_retention  = var.vault_lock_min_retention
  vault_lock_max_retention  = var.vault_lock_max_retention
  vault_lock_changeable_days = var.vault_lock_changeable_days

  # Notifications
  sns_topic_arn = module.monitoring.sns_topic_arn
  notification_events = [
    "BACKUP_JOB_STARTED",
    "BACKUP_JOB_COMPLETED",
    "BACKUP_JOB_FAILED",
    "RESTORE_JOB_COMPLETED",
    "RESTORE_JOB_FAILED"
  ]
}

#------------------------------------------------------------------------------
# Well-Architected Framework: Cost Optimization (AWS Budgets)
#------------------------------------------------------------------------------

module "budgets" {
  source = "../../modules/aws/well-architected/cost-optimization/budgets"
  count  = var.enable_budgets ? 1 : 0

  name_prefix = local.name_prefix
  common_tags = local.all_tags
  environment = local.environment

  # Monthly cost budget
  enable_cost_budget     = true
  monthly_budget_amount  = var.monthly_budget_amount
  alert_thresholds       = var.budget_alert_thresholds
  enable_forecast_alert  = true
  forecast_threshold     = var.budget_forecast_threshold

  # Alert recipients
  alert_emails   = var.budget_alert_emails
  sns_topic_arns = [module.monitoring.sns_topic_arn]

  # Budget filters (optional)
  cost_filter_tags = var.budget_cost_filter_tags

  # Service-specific budgets
  enable_service_budgets      = var.enable_service_budgets
  ec2_budget_amount           = var.ec2_budget_amount
  rds_budget_amount           = var.rds_budget_amount
  data_transfer_budget_amount = var.data_transfer_budget_amount

  # Usage budget
  enable_usage_budget    = var.enable_usage_budget
  ec2_usage_hours_limit  = var.ec2_usage_hours_limit

  # Budget actions (auto-remediation)
  enable_budget_actions    = var.enable_budget_actions
  budget_action_approval   = var.budget_action_approval
  action_threshold         = var.budget_action_threshold
  ec2_instance_ids_to_stop = var.budget_ec2_instances_to_stop
}
