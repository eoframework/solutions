#------------------------------------------------------------------------------
# AWS Well-Architected Best Practices - DR Environment
#------------------------------------------------------------------------------
# DR DIFFERENCES:
# - backup.enabled: FALSE (DR receives backups, doesn't create)
# - guardduty_enhanced.enabled: FALSE (managed at production)
# - config_rules.enabled: Optional
# - budget.enabled: TRUE (monitor DR costs)
#------------------------------------------------------------------------------

backup = {
  # DR does NOT create backups - it RECEIVES them from production
  enabled = false

  backup_tag_key             = "Backup"
  backup_tag_value           = "true"
  cold_storage_days          = 90
  daily_retention            = 30
  daily_schedule             = "cron(0 5 * * ? *)"
  dr_retention               = 30
  enable_continuous          = false
  enable_cross_region        = false
  enable_monthly             = true
  enable_s3_backup           = false
  enable_tag_selection       = true
  enable_vault_lock          = false
  enable_vault_policy        = true
  enable_weekly              = true
  enable_windows_vss         = false
  monthly_retention          = 365
  monthly_schedule           = "cron(0 5 1 * ? *)"
  notification_events        = ["BACKUP_JOB_STARTED", "BACKUP_JOB_COMPLETED", "BACKUP_JOB_FAILED", "RESTORE_JOB_STARTED", "RESTORE_JOB_COMPLETED", "RESTORE_JOB_FAILED"]
  resource_arns              = []
  vault_lock_changeable_days = 3
  vault_lock_max_retention   = 365
  vault_lock_min_retention   = 7
  weekly_retention           = 90
  weekly_schedule            = "cron(0 5 ? * SUN *)"
}

budget = {
  enabled = true

  action_approval             = "MANUAL"
  action_threshold            = 150
  alert_emails                = []
  alert_thresholds            = [50, 80, 100]
  budget_currency             = "USD"
  budget_time_unit            = "MONTHLY"
  data_transfer_budget_amount = 0
  ec2_budget_amount           = 0
  ec2_instances_to_stop       = []
  ec2_usage_hours_limit       = 1000
  enable_actions              = false
  enable_cost_budget          = true
  enable_forecast_alert       = true
  enable_service_budgets      = false
  enable_usage_budget         = false
  forecast_threshold          = 100
  monthly_amount              = 500
  notification_comparison     = "GREATER_THAN"
  notification_threshold_type = "PERCENTAGE"
  notification_type           = "ACTUAL"
  rds_budget_amount           = 0
  service_alert_threshold     = 80
}

config_rules = {
  enabled = false

  delivery_frequency        = "TwentyFour_Hours"
  enable_cost_rules         = false
  enable_operational_rules  = true
  enable_recorder           = false
  enable_reliability_rules  = true
  enable_security_rules     = true
  excluded_resource_types   = []
  include_global_resources  = true
  min_backup_retention_days = 7
  record_all_resources      = true
  retention_days            = 365
}

guardduty_enhanced = {
  # DISABLED for DR - managed at production
  enabled = false

  enable_eks_protection     = false
  enable_malware_protection = false
  enable_s3_export          = false
  findings_retention_days   = 365
  severity_threshold        = 7
}
