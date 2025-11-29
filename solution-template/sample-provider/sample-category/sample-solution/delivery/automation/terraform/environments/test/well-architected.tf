# Well-Architected Framework - Test Environment
#
# MINIMAL configuration for test environments:
# - Most governance features DISABLED by default
# - Reduced retention periods
# - No cross-region backup
# - Optional budget alerts for cost visibility
#
# Test environments prioritize:
# - Fast iteration and easy teardown
# - Cost efficiency
# - Developer productivity
#
# Enable specific features via well-architected.tfvars if needed for testing

#------------------------------------------------------------------------------
# Operational Excellence: AWS Config Rules (OPTIONAL for test)
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
# Reliability: AWS Backup Plans (OPTIONAL for test)
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
# Cost Optimization: AWS Budgets (RECOMMENDED for test)
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

#------------------------------------------------------------------------------
# Outputs for Well-Architected Resources
#------------------------------------------------------------------------------

output "config_rules_enabled" {
  description = "Whether AWS Config rules are enabled"
  value       = var.enable_config_rules
}

output "backup_vault_arn" {
  description = "AWS Backup vault ARN"
  value       = var.enable_backup_plans ? module.backup_plans[0].vault_arn : null
}

output "backup_plan_id" {
  description = "AWS Backup plan ID"
  value       = var.enable_backup_plans ? module.backup_plans[0].backup_plan_id : null
}

output "monthly_budget_name" {
  description = "Monthly cost budget name"
  value       = var.enable_budgets ? module.budgets[0].monthly_budget_name : null
}
