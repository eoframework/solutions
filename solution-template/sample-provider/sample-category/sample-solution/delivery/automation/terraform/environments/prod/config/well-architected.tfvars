#------------------------------------------------------------------------------
# AWS Well-Architected Framework Configuration
#------------------------------------------------------------------------------
# This file configures governance and compliance resources aligned with
# the AWS Well-Architected Framework six pillars:
#
# 1. Operational Excellence - AWS Config for compliance monitoring
# 2. Security - Enhanced GuardDuty for threat detection
# 3. Reliability - AWS Backup for centralized backup management
# 4. Performance Efficiency - (handled via compute/cache modules)
# 5. Cost Optimization - AWS Budgets for cost alerting
# 6. Sustainability - (handled via right-sizing in other modules)
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Operational Excellence: AWS Config Rules
#------------------------------------------------------------------------------

enable_config_rules    = true
enable_config_recorder = true
# config_bucket_name   = ""      # Auto-generated: {name_prefix}-config
config_retention_days  = 365

#------------------------------------------------------------------------------
# Security: Enhanced GuardDuty
#------------------------------------------------------------------------------
# Note: Basic GuardDuty may already be enabled via the security module.
# Set enable_guardduty_enhanced = true for additional protections like
# S3 protection, EKS protection, and malware scanning.

enable_guardduty_enhanced   = false    # Set true if not using security module
enable_eks_protection       = false    # Enable if using EKS
enable_malware_protection   = true
# guardduty_findings_bucket = ""       # Auto-generated if empty
guardduty_severity_threshold = 7       # Alert on High/Critical only

#------------------------------------------------------------------------------
# Reliability: AWS Backup
#------------------------------------------------------------------------------

enable_backup_plans = true

# Daily backups (retain 30 days)
backup_daily_schedule   = "cron(0 5 * * ? *)"     # 5 AM UTC daily
backup_daily_retention  = 30

# Weekly backups (retain 90 days)
backup_weekly_schedule  = "cron(0 5 ? * SUN *)"   # Sunday 5 AM UTC
backup_weekly_retention = 90

# Monthly backups (retain 1 year, cold storage after 90 days)
backup_monthly_schedule   = "cron(0 5 1 * ? *)"   # 1st of month 5 AM UTC
backup_monthly_retention  = 365
backup_cold_storage_days  = 90

# Cross-region DR (optional)
enable_backup_cross_region = false
backup_dr_retention        = 30
# dr_kms_key_arn           = ""        # Required if cross-region enabled

# Advanced options
enable_continuous_backup  = false      # Point-in-time recovery
enable_windows_vss        = false      # Windows application-consistent backups

# Compliance (WORM)
enable_backup_vault_lock    = false
vault_lock_min_retention    = 7
vault_lock_max_retention    = 365
vault_lock_changeable_days  = 3

#------------------------------------------------------------------------------
# Cost Optimization: AWS Budgets
#------------------------------------------------------------------------------

enable_budgets = true

# Monthly cost budget
monthly_budget_amount    = 1000          # Adjust to expected monthly spend
budget_alert_thresholds  = [50, 80, 100] # Alert at 50%, 80%, 100%
budget_forecast_threshold = 100          # Alert if forecast exceeds 100%

# Alert recipients
budget_alert_emails = [
  # "finance@example.com",
  # "team-lead@example.com"
]

# Service-specific budgets (optional)
enable_service_budgets      = false
ec2_budget_amount           = 0          # 0 = disabled
rds_budget_amount           = 0
data_transfer_budget_amount = 0

# Usage budget (optional)
enable_usage_budget   = false
ec2_usage_hours_limit = 1000

# Budget actions - automated cost control (use with caution!)
enable_budget_actions     = false
budget_action_approval    = "MANUAL"     # MANUAL or AUTOMATIC
budget_action_threshold   = 100
budget_ec2_instances_to_stop = [
  # "i-1234567890abcdef0"   # Non-critical instances to stop
]
