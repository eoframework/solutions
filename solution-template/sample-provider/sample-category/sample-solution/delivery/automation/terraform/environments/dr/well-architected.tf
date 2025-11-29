# Well-Architected Framework - DR Environment
#
# DR-specific configuration emphasizing:
# - Reliability: AWS Backup for cross-region recovery
# - Cost Optimization: Budget monitoring for DR infrastructure
# - Operational Excellence: Config rules for compliance (optional)
#
# Note: Security (WAF, GuardDuty) is managed at the primary site.
# DR focuses on data protection and failover readiness.

#------------------------------------------------------------------------------
# Operational Excellence: AWS Config Rules (OPTIONAL for DR)
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
# Reliability: AWS Backup Plans (CRITICAL for DR)
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
# Cost Optimization: AWS Budgets (ENABLED for DR)
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
