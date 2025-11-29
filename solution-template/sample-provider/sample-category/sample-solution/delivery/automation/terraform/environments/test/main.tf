# Test Environment - Minimal Deployment
#
# Composes: core + database (minimal)
#
# This is a minimal test deployment with:
# - VPC, ALB, ASG with reduced capacity (core)
# - RDS single-AZ, smaller instance (database)
# - NO cache (not needed for testing)
# - NO security extras (no WAF, GuardDuty)
# - NO monitoring dashboard (minimal logging only)
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
  single_nat_gateway    = var.single_nat_gateway  # true for test (cost savings)
  enable_flow_logs      = var.enable_flow_logs
  flow_log_retention_days = var.flow_log_retention_days

  # Security
  allowed_https_cidrs     = var.allowed_https_cidrs
  allowed_http_cidrs      = var.allowed_http_cidrs
  allowed_ssh_cidrs       = var.allowed_ssh_cidrs
  enable_ssh_access       = var.enable_ssh_access  # true for test (debugging)
  enable_kms_encryption   = var.enable_kms_encryption
  enable_instance_profile = var.enable_instance_profile
  enable_ssm_access       = var.enable_ssm_access
  require_imdsv2          = var.require_imdsv2
  metadata_hop_limit      = var.metadata_hop_limit

  # Compute (smaller instances for test)
  instance_type              = var.instance_type  # t3.medium for test
  use_latest_ami             = var.use_latest_ami
  root_volume_size           = var.root_volume_size  # 50GB for test
  root_volume_type           = var.root_volume_type
  root_volume_iops           = var.root_volume_iops
  root_volume_throughput     = var.root_volume_throughput
  enable_detailed_monitoring = var.enable_detailed_monitoring  # false for test

  # Auto Scaling (minimal capacity for test)
  enable_auto_scaling       = var.enable_auto_scaling
  asg_min_size              = var.asg_min_size  # 1 for test
  asg_max_size              = var.asg_max_size  # 3 for test
  asg_desired_capacity      = var.asg_desired_capacity  # 1 for test
  health_check_grace_period = var.health_check_grace_period
  scale_up_threshold        = var.scale_up_threshold
  scale_down_threshold      = var.scale_down_threshold

  # Load Balancer
  enable_alb                    = var.enable_alb
  alb_internal                  = var.alb_internal
  enable_lb_deletion_protection = var.enable_lb_deletion_protection  # false for test
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
# Database (RDS - Minimal Configuration)
#------------------------------------------------------------------------------

module "database" {
  source = "../../modules/solution/database"

  name_prefix          = local.name_prefix
  common_tags          = local.all_tags
  environment          = local.environment
  db_subnet_group_name = module.core.db_subnet_group_name
  security_group_ids   = [module.core.database_security_group_id]

  # Engine (same as production for compatibility testing)
  db_engine         = var.db_engine
  db_engine_version = var.db_engine_version
  db_instance_class = var.db_instance_class  # db.t3.medium for test

  # Storage (smaller for test)
  db_allocated_storage     = var.db_allocated_storage  # 20GB for test
  db_max_allocated_storage = var.db_max_allocated_storage  # 50GB for test
  db_storage_encrypted     = var.db_storage_encrypted

  # Database
  db_name     = var.db_name
  db_username = var.db_username
  db_password = var.db_password

  # High Availability (disabled for test)
  db_multi_az = false  # Always single-AZ for test

  # Backup (minimal for test)
  db_backup_retention   = var.db_backup_retention  # 7 days for test
  db_backup_window      = var.db_backup_window
  db_maintenance_window = var.db_maintenance_window

  # Monitoring (disabled for test)
  db_performance_insights = false  # Disabled for test

  # Protection (disabled for test - allow easy teardown)
  db_deletion_protection = false  # Always false for test

  # Alarms (disabled for test)
  enable_alarms = false
}

# NOTE: The following modules are NOT included in test environment:
#
# - module "cache" - Not needed for testing (use in-memory caching or mock)
# - module "security" - WAF, GuardDuty, CloudTrail not needed for test
# - module "monitoring" - Dashboard and X-Ray not needed for test
#
# This reduces costs and complexity for the test environment.
# If specific testing requires these features, add them as needed.

#------------------------------------------------------------------------------
# Well-Architected Framework: Operational Excellence (AWS Config - OPTIONAL)
#------------------------------------------------------------------------------
# Disabled by default - enable if testing compliance features

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
  enable_bucket_versioning = false  # Disabled for test
  enable_bucket_encryption = false  # Disabled for test (no KMS)

  # Rule categories - minimal for test
  enable_security_rules    = var.enable_config_security_rules
  enable_reliability_rules = false
  enable_operational_rules = false
  enable_cost_rules        = false
}

#------------------------------------------------------------------------------
# Well-Architected Framework: Reliability (AWS Backup - OPTIONAL)
#------------------------------------------------------------------------------
# Disabled by default - test data is ephemeral

module "backup_plans" {
  source = "../../modules/aws/well-architected/reliability/backup-plans"
  count  = var.enable_backup_plans ? 1 : 0

  name_prefix = local.name_prefix
  common_tags = local.all_tags

  # No KMS encryption for test (simpler setup)
  kms_key_arn    = null
  dr_kms_key_arn = null

  # Daily backup only (minimal retention)
  daily_backup_schedule = var.backup_daily_schedule
  daily_retention_days  = var.backup_daily_retention

  # Disable weekly/monthly for test
  enable_weekly_backup  = false
  enable_monthly_backup = false

  # No cross-region for test
  enable_cross_region_copy = false

  # Resource selection
  enable_tag_based_selection = true
  backup_tag_key             = "Backup"
  backup_tag_value           = "true"

  # Disable advanced features
  enable_continuous_backup = false
  enable_windows_vss       = false
  enable_vault_lock        = false
}

#------------------------------------------------------------------------------
# Well-Architected Framework: Cost Optimization (AWS Budgets - RECOMMENDED)
#------------------------------------------------------------------------------
# Enabled by default - helps catch runaway test costs

module "budgets" {
  source = "../../modules/aws/well-architected/cost-optimization/budgets"
  count  = var.enable_budgets ? 1 : 0

  name_prefix = local.name_prefix
  common_tags = local.all_tags
  environment = local.environment

  # Low budget for test environment
  enable_cost_budget    = true
  monthly_budget_amount = var.monthly_budget_amount
  alert_thresholds      = var.budget_alert_thresholds
  enable_forecast_alert = true
  forecast_threshold    = var.budget_forecast_threshold

  # Alert recipients
  alert_emails   = var.budget_alert_emails
  sns_topic_arns = []  # No SNS in test environment

  # No service-specific budgets for test
  enable_service_budgets = false

  # No budget actions for test
  enable_budget_actions = false
}
