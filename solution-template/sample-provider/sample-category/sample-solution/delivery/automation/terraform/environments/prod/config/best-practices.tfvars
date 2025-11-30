#------------------------------------------------------------------------------
# Best Practices Configuration - PRODUCTION Environment
#------------------------------------------------------------------------------
# Aligned with AWS Well-Architected Framework 6 pillars:
#
# IN THIS FILE:
#   Cost Optimization     - Budgets, alerts, cold storage tiering
#   Reliability           - Backup plans, retention policies, DR
#   Operational Excellence - AWS Config, compliance monitoring
#
# IN OTHER CONFIG FILES (cross-reference):
#   Security              - See security.tfvars (WAF, GuardDuty, KMS, IAM)
#   Performance Efficiency - See compute.tfvars (instance types, scaling)
#                           See cache.tfvars (caching layer)
#   Sustainability        - Achieved via right-sizing in compute.tfvars
#                           Consider Graviton instances for lower carbon
#------------------------------------------------------------------------------

config_rules = {
  #----------------------------------------------------------------------------
  # Operational Excellence: AWS Config Rules
  #----------------------------------------------------------------------------
  enabled          = true
  enable_recorder  = true
  # bucket_name    = ""        # Auto-generated: {name_prefix}-config
  retention_days   = 365

  #----------------------------------------------------------------------------
  # Rule Categories - Toggle by category
  #----------------------------------------------------------------------------
  enable_security_rules     = true    # Encryption, access controls
  enable_reliability_rules  = true    # Multi-AZ, backups
  enable_operational_rules  = true    # CloudTrail, CloudWatch
  enable_cost_rules         = true    # EBS optimization

  #----------------------------------------------------------------------------
  # Rule Parameters
  #----------------------------------------------------------------------------
  min_backup_retention_days = 7       # Minimum backup retention for compliance

  #----------------------------------------------------------------------------
  # Config Recorder Settings
  #----------------------------------------------------------------------------
  record_all_resources      = true
  include_global_resources  = true
  excluded_resource_types   = []
  delivery_frequency        = "TwentyFour_Hours"  # One_Hour, Three_Hours, Six_Hours, Twelve_Hours, TwentyFour_Hours
}

guardduty_enhanced = {
  #----------------------------------------------------------------------------
  # Security: Enhanced GuardDuty
  #----------------------------------------------------------------------------
  # Note: Basic GuardDuty may already be enabled via the security module.
  # Set enabled = true for additional protections like S3 protection,
  # EKS protection, and malware scanning.
  enabled                   = false    # Set true if not using security module
  enable_eks_protection     = false    # Enable if using EKS
  enable_malware_protection = true
  # findings_bucket         = ""       # Auto-generated if empty
  severity_threshold        = 7        # Alert on High/Critical only (1-10)

  #----------------------------------------------------------------------------
  # Findings Export
  #----------------------------------------------------------------------------
  enable_s3_export          = true
  findings_retention_days   = 365
}

backup = {
  #----------------------------------------------------------------------------
  # Reliability: AWS Backup
  #----------------------------------------------------------------------------
  enabled = true

  #----------------------------------------------------------------------------
  # Daily Backups
  #----------------------------------------------------------------------------
  daily_schedule   = "cron(0 5 * * ? *)"     # 5 AM UTC daily
  daily_retention  = 30                       # days

  #----------------------------------------------------------------------------
  # Weekly Backups
  #----------------------------------------------------------------------------
  enable_weekly    = true
  weekly_schedule  = "cron(0 5 ? * SUN *)"   # Sunday 5 AM UTC
  weekly_retention = 90                       # days

  #----------------------------------------------------------------------------
  # Monthly Backups
  #----------------------------------------------------------------------------
  enable_monthly     = true
  monthly_schedule   = "cron(0 5 1 * ? *)"   # 1st of month 5 AM UTC
  monthly_retention  = 365                    # days
  cold_storage_days  = 90                     # Move to cold storage after 90 days

  #----------------------------------------------------------------------------
  # Cross-Region DR
  #----------------------------------------------------------------------------
  enable_cross_region = false
  dr_retention        = 30
  # dr_kms_key_arn    = ""        # Required if cross-region enabled

  #----------------------------------------------------------------------------
  # Resource Selection
  #----------------------------------------------------------------------------
  enable_tag_selection = true
  backup_tag_key       = "Backup"
  backup_tag_value     = "true"
  resource_arns        = []       # Specific ARNs to backup (in addition to tagged)

  #----------------------------------------------------------------------------
  # Advanced Options
  #----------------------------------------------------------------------------
  enable_continuous  = false      # Point-in-time recovery (RDS, S3)
  enable_windows_vss = false      # Windows application-consistent backups
  enable_s3_backup   = false      # S3 bucket backup support
  enable_vault_policy = true      # Vault access policy

  #----------------------------------------------------------------------------
  # Compliance (WORM - Write Once Read Many)
  #----------------------------------------------------------------------------
  enable_vault_lock          = false
  vault_lock_min_retention   = 7
  vault_lock_max_retention   = 365
  vault_lock_changeable_days = 3

  #----------------------------------------------------------------------------
  # Notifications
  #----------------------------------------------------------------------------
  notification_events = [
    "BACKUP_JOB_STARTED",
    "BACKUP_JOB_COMPLETED",
    "BACKUP_JOB_FAILED",
    "RESTORE_JOB_STARTED",
    "RESTORE_JOB_COMPLETED",
    "RESTORE_JOB_FAILED"
  ]
}

budget = {
  #----------------------------------------------------------------------------
  # Cost Optimization: AWS Budgets
  #----------------------------------------------------------------------------
  enabled = true

  #----------------------------------------------------------------------------
  # Monthly Cost Budget
  #----------------------------------------------------------------------------
  enable_cost_budget = true
  monthly_amount     = 1000               # Adjust to expected monthly spend
  budget_currency    = "USD"
  budget_time_unit   = "MONTHLY"          # MONTHLY, QUARTERLY, ANNUALLY

  #----------------------------------------------------------------------------
  # Alert Thresholds
  #----------------------------------------------------------------------------
  alert_thresholds   = [50, 80, 100]      # Alert at 50%, 80%, 100%
  enable_forecast_alert = true
  forecast_threshold = 100                 # Alert if forecast exceeds 100%

  #----------------------------------------------------------------------------
  # Notification Settings
  #----------------------------------------------------------------------------
  notification_comparison    = "GREATER_THAN"
  notification_threshold_type = "PERCENTAGE"
  notification_type          = "ACTUAL"    # ACTUAL or FORECASTED

  #----------------------------------------------------------------------------
  # Alert Recipients
  #----------------------------------------------------------------------------
  alert_emails = [
    # "finance@example.com",
    # "team-lead@example.com"
  ]

  #----------------------------------------------------------------------------
  # Service-Specific Budgets
  #----------------------------------------------------------------------------
  enable_service_budgets      = false
  ec2_budget_amount           = 0         # 0 = disabled
  rds_budget_amount           = 0
  data_transfer_budget_amount = 0
  service_alert_threshold     = 80        # Percentage for service budgets

  #----------------------------------------------------------------------------
  # Usage Budget
  #----------------------------------------------------------------------------
  enable_usage_budget   = false
  ec2_usage_hours_limit = 1000

  #----------------------------------------------------------------------------
  # Budget Actions - Automated Cost Control
  #----------------------------------------------------------------------------
  # WARNING: Use with caution in production!
  enable_actions     = false
  action_approval    = "MANUAL"           # MANUAL or AUTOMATIC
  action_threshold   = 100
  ec2_instances_to_stop = [
    # "i-1234567890abcdef0"   # Non-critical instances to stop
  ]
}
