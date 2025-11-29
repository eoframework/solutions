# DR Environment - Disaster Recovery Deployment
#
# Composes: core + database + cache + monitoring
#
# This is a DR deployment with:
# - VPC, ALB, ASG in alternate region (core)
# - RDS with Multi-AZ and cross-region read replica support (database)
# - ElastiCache Redis cluster (cache)
# - CloudWatch monitoring for DR alerting (monitoring)
# - NO WAF/GuardDuty (managed at primary site)
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
  # Example: vxr-dr, sfi-dr, pci-dr
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
    # DR-specific tags
    Purpose      = "DisasterRecovery"
    Standby      = "true"
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

  # Networking (mirror production topology)
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
  enable_instance_profile = var.enable_instance_profile
  enable_ssm_access       = var.enable_ssm_access
  require_imdsv2          = var.require_imdsv2
  metadata_hop_limit      = var.metadata_hop_limit

  # Compute (same as production for failover capability)
  instance_type              = var.instance_type
  use_latest_ami             = var.use_latest_ami
  root_volume_size           = var.root_volume_size
  root_volume_type           = var.root_volume_type
  root_volume_iops           = var.root_volume_iops
  root_volume_throughput     = var.root_volume_throughput
  enable_detailed_monitoring = var.enable_detailed_monitoring

  # Auto Scaling (reduced capacity in standby mode)
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
# Database (RDS - DR Configuration with Read Replica Support)
#------------------------------------------------------------------------------

module "database" {
  source = "../../modules/solution/database"

  name_prefix          = local.name_prefix
  common_tags          = local.all_tags
  environment          = local.environment
  db_subnet_group_name = module.core.db_subnet_group_name
  security_group_ids   = [module.core.database_security_group_id]

  # Engine (must match production for replication)
  db_engine         = var.db_engine
  db_engine_version = var.db_engine_version
  db_instance_class = var.db_instance_class

  # Storage (same as production)
  db_allocated_storage     = var.db_allocated_storage
  db_max_allocated_storage = var.db_max_allocated_storage
  db_storage_encrypted     = var.db_storage_encrypted

  # Database
  db_name     = var.db_name
  db_username = var.db_username
  db_password = var.db_password

  # High Availability (enabled for DR)
  db_multi_az = var.db_multi_az

  # Backup (same as production for recovery)
  db_backup_retention   = var.db_backup_retention
  db_backup_window      = var.db_backup_window
  db_maintenance_window = var.db_maintenance_window

  # Monitoring
  db_performance_insights = var.db_performance_insights

  # Protection (enabled for DR)
  db_deletion_protection = var.db_deletion_protection

  # Alarms
  enable_alarms       = true
  alarm_sns_topic_arn = module.monitoring.sns_topic_arn
}

#------------------------------------------------------------------------------
# Cache (ElastiCache Redis - DR Configuration)
#------------------------------------------------------------------------------

module "cache" {
  source = "../../modules/solution/cache"

  name_prefix        = local.name_prefix
  common_tags        = local.all_tags
  subnet_ids         = module.core.private_subnet_ids
  security_group_ids = [module.core.cache_security_group_id]

  # Engine (same as production)
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
# Monitoring (CloudWatch - DR Alerting)
#------------------------------------------------------------------------------

module "monitoring" {
  source = "../../modules/solution/monitoring"

  name_prefix  = local.name_prefix
  common_tags  = local.all_tags
  project_name = var.solution_name
  environment  = local.environment

  # Resource references
  alb_arn          = module.core.alb_arn
  asg_name         = module.core.asg_name
  rds_identifier   = module.database.rds_identifier
  cache_cluster_id = module.cache.cache_replication_group_id

  # Logging
  log_retention_days        = var.log_retention_days
  enable_container_insights = var.enable_container_insights

  # Dashboard (enabled for DR visibility)
  enable_dashboard = var.enable_dashboard

  # Alerting (critical for DR)
  alarm_email = var.alarm_email

  # X-Ray
  enable_xray_tracing = var.enable_xray_tracing
}

# NOTE: Security module (WAF, GuardDuty) is NOT included in DR environment.
# Security controls are managed at the primary site level.
# CloudTrail can be added if cross-region audit logging is required.

#------------------------------------------------------------------------------
# Well-Architected Framework: Operational Excellence (AWS Config - OPTIONAL)
#------------------------------------------------------------------------------
# Enable if DR region requires independent compliance monitoring

module "config_rules" {
  source = "../../modules/aws/well-architected/operational-excellence/config-rules"
  count  = var.enable_config_rules ? 1 : 0

  name_prefix = local.name_prefix
  common_tags = local.all_tags

  # Config Recorder
  enable_config_recorder = var.enable_config_recorder

  # S3 for Config delivery
  config_bucket_name       = var.config_bucket_name != "" ? var.config_bucket_name : "${local.name_prefix}-config"
  config_bucket_prefix     = "config"
  config_retention_days    = var.config_retention_days
  enable_bucket_versioning = true
  enable_bucket_encryption = true

  # Rule categories - focus on reliability for DR
  enable_security_rules    = true
  enable_reliability_rules = true
  enable_operational_rules = true
  enable_cost_rules        = false

  # Notifications via monitoring module
  sns_topic_arn = module.monitoring.sns_topic_arn
}

#------------------------------------------------------------------------------
# Well-Architected Framework: Reliability (AWS Backup - CRITICAL)
#------------------------------------------------------------------------------
# Backup is essential for DR - receives cross-region copies from production

module "backup_plans" {
  source = "../../modules/aws/well-architected/reliability/backup-plans"
  count  = var.enable_backup_plans ? 1 : 0

  name_prefix = local.name_prefix
  common_tags = local.all_tags

  # Encryption (uses DR region's KMS key)
  kms_key_arn    = var.dr_kms_key_arn
  dr_kms_key_arn = null  # DR doesn't copy to another region

  # Daily backup (local DR backups)
  daily_backup_schedule = var.backup_daily_schedule
  daily_retention_days  = var.backup_daily_retention

  # Weekly backup
  enable_weekly_backup   = true
  weekly_backup_schedule = var.backup_weekly_schedule
  weekly_retention_days  = var.backup_weekly_retention

  # Monthly backup (archive)
  enable_monthly_backup     = var.enable_monthly_backup
  monthly_backup_schedule   = var.backup_monthly_schedule
  monthly_retention_days    = var.backup_monthly_retention
  monthly_cold_storage_days = var.backup_cold_storage_days

  # No outbound cross-region copy (DR is the destination)
  enable_cross_region_copy = false

  # Resource selection
  enable_tag_based_selection = true
  backup_tag_key             = "Backup"
  backup_tag_value           = "true"
  resource_arns              = var.backup_resource_arns

  # Additional features
  enable_continuous_backup = var.enable_continuous_backup
  enable_windows_vss       = var.enable_windows_vss

  # Compliance (vault lock for immutable backups)
  enable_vault_lock          = var.enable_backup_vault_lock
  vault_lock_min_retention   = var.vault_lock_min_retention
  vault_lock_max_retention   = var.vault_lock_max_retention
  vault_lock_changeable_days = var.vault_lock_changeable_days

  # Notifications via monitoring module
  sns_topic_arn = module.monitoring.sns_topic_arn
  notification_events = [
    "BACKUP_JOB_STARTED",
    "BACKUP_JOB_COMPLETED",
    "BACKUP_JOB_FAILED",
    "RESTORE_JOB_STARTED",
    "RESTORE_JOB_COMPLETED",
    "RESTORE_JOB_FAILED",
    "COPY_JOB_STARTED",
    "COPY_JOB_SUCCESSFUL",
    "COPY_JOB_FAILED"
  ]
}

#------------------------------------------------------------------------------
# Well-Architected Framework: Cost Optimization (AWS Budgets)
#------------------------------------------------------------------------------
# Monitor DR infrastructure costs

module "budgets" {
  source = "../../modules/aws/well-architected/cost-optimization/budgets"
  count  = var.enable_budgets ? 1 : 0

  name_prefix = local.name_prefix
  common_tags = local.all_tags
  environment = local.environment

  # Monthly cost budget
  enable_cost_budget    = true
  monthly_budget_amount = var.monthly_budget_amount
  alert_thresholds      = var.budget_alert_thresholds
  enable_forecast_alert = true
  forecast_threshold    = var.budget_forecast_threshold

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
  enable_usage_budget   = var.enable_usage_budget
  ec2_usage_hours_limit = var.ec2_usage_hours_limit

  # Budget actions (auto-remediation - use with caution in DR)
  enable_budget_actions    = var.enable_budget_actions
  budget_action_approval   = var.budget_action_approval
  action_threshold         = var.budget_action_threshold
  ec2_instance_ids_to_stop = var.budget_ec2_instances_to_stop
}
