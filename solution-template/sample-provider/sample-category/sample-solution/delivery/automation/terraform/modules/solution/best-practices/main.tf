#------------------------------------------------------------------------------
# Best Practices Module
#------------------------------------------------------------------------------
# Consolidated module for AWS best practices aligned with Well-Architected Framework:
# - Operational Excellence: AWS Config Rules
# - Security: Enhanced GuardDuty
# - Reliability: AWS Backup Plans
# - Cost Optimization: AWS Budgets
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Operational Excellence: AWS Config Rules
#------------------------------------------------------------------------------

module "config_rules" {
  source = "../../aws/best-practices/operational-excellence/config-rules"
  count  = var.config_rules.enabled ? 1 : 0

  name_prefix = var.name_prefix
  common_tags = var.common_tags

  # Config Recorder
  enable_config_recorder = var.config_rules.enable_recorder

  # S3 for Config delivery
  config_bucket_name       = var.config_bucket_name != "" ? var.config_bucket_name : "${var.name_prefix}-config"
  config_bucket_prefix     = "config"
  config_retention_days    = var.config_rules.retention_days
  enable_bucket_versioning = true
  enable_bucket_encryption = true

  # Rule categories
  enable_security_rules    = true
  enable_reliability_rules = true
  enable_operational_rules = true
  enable_cost_rules        = true

  # Notifications
  sns_topic_arn = var.sns_topic_arn
}

#------------------------------------------------------------------------------
# Security: Enhanced GuardDuty
#------------------------------------------------------------------------------

module "guardduty_enhanced" {
  source = "../../aws/best-practices/security/guardduty"
  count  = var.guardduty_enhanced.enabled ? 1 : 0

  name_prefix = var.name_prefix
  common_tags = var.common_tags

  # Protection features
  enable_s3_protection      = true
  enable_eks_protection     = var.guardduty_enhanced.enable_eks_protection
  enable_malware_protection = var.guardduty_enhanced.enable_malware_protection

  # Findings export
  enable_findings_export = true
  findings_bucket_name   = var.guardduty_findings_bucket != "" ? var.guardduty_findings_bucket : "${var.name_prefix}-guardduty-findings"
  kms_key_arn            = var.kms_key_arn

  # Alerting
  enable_sns_notifications = true
  sns_topic_arn            = var.sns_topic_arn
  high_severity_threshold  = var.guardduty_enhanced.severity_threshold
}

#------------------------------------------------------------------------------
# Reliability: AWS Backup Plans
#------------------------------------------------------------------------------

module "backup_plans" {
  source = "../../aws/best-practices/reliability/backup-plans"
  count  = var.backup.enabled ? 1 : 0

  name_prefix = var.name_prefix
  common_tags = var.common_tags

  # Encryption
  kms_key_arn    = var.kms_key_arn
  dr_kms_key_arn = var.dr_kms_key_arn

  # Daily backup
  daily_backup_schedule = var.backup.daily_schedule
  daily_retention_days  = var.backup.daily_retention

  # Weekly backup
  enable_weekly_backup   = true
  weekly_backup_schedule = var.backup.weekly_schedule
  weekly_retention_days  = var.backup.weekly_retention

  # Monthly backup
  enable_monthly_backup     = true
  monthly_backup_schedule   = var.backup.monthly_schedule
  monthly_retention_days    = var.backup.monthly_retention
  monthly_cold_storage_days = var.backup.cold_storage_days

  # Cross-region DR copy
  enable_cross_region_copy = var.backup.enable_cross_region
  dr_retention_days        = var.backup.dr_retention

  # Resource selection
  enable_tag_based_selection = true
  backup_tag_key             = "Backup"
  backup_tag_value           = "true"

  # Additional features
  enable_continuous_backup = var.backup.enable_continuous
  enable_windows_vss       = var.backup.enable_windows_vss

  # Compliance (vault lock)
  enable_vault_lock          = var.backup.enable_vault_lock
  vault_lock_min_retention   = var.backup.vault_lock_min_retention
  vault_lock_max_retention   = var.backup.vault_lock_max_retention
  vault_lock_changeable_days = var.backup.vault_lock_changeable_days

  # Notifications
  sns_topic_arn = var.sns_topic_arn
  notification_events = [
    "BACKUP_JOB_STARTED",
    "BACKUP_JOB_COMPLETED",
    "BACKUP_JOB_FAILED",
    "RESTORE_JOB_COMPLETED",
    "RESTORE_JOB_FAILED"
  ]
}

#------------------------------------------------------------------------------
# Cost Optimization: AWS Budgets
#------------------------------------------------------------------------------

module "budgets" {
  source = "../../aws/best-practices/cost-optimization/budgets"
  count  = var.budget.enabled ? 1 : 0

  name_prefix = var.name_prefix
  common_tags = var.common_tags
  environment = var.environment

  # Monthly cost budget
  enable_cost_budget    = true
  monthly_budget_amount = var.budget.monthly_amount
  alert_thresholds      = var.budget.alert_thresholds
  enable_forecast_alert = true
  forecast_threshold    = var.budget.forecast_threshold

  # Alert recipients
  alert_emails   = var.budget.alert_emails
  sns_topic_arns = [var.sns_topic_arn]

  # Service-specific budgets
  enable_service_budgets      = var.budget.enable_service_budgets
  ec2_budget_amount           = var.budget.ec2_budget_amount
  rds_budget_amount           = var.budget.rds_budget_amount
  data_transfer_budget_amount = var.budget.data_transfer_budget_amount

  # Usage budget
  enable_usage_budget   = var.budget.enable_usage_budget
  ec2_usage_hours_limit = var.budget.ec2_usage_hours_limit

  # Budget actions (auto-remediation)
  enable_budget_actions    = var.budget.enable_actions
  budget_action_approval   = var.budget.action_approval
  action_threshold         = var.budget.action_threshold
  ec2_instance_ids_to_stop = var.budget.ec2_instances_to_stop
}
