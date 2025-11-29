#------------------------------------------------------------------------------
# AWS Well-Architected Framework Configuration - DR ENVIRONMENT
#------------------------------------------------------------------------------
# DR-focused governance emphasizing:
# - Data protection and backup (CRITICAL)
# - Cost monitoring for standby infrastructure
# - Compliance monitoring (OPTIONAL - can mirror primary)
#
# Note: Security controls (WAF, GuardDuty) are managed at primary site.
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Operational Excellence: AWS Config Rules
#------------------------------------------------------------------------------
# OPTIONAL - Enable if DR region requires independent compliance monitoring
# Usually mirrors primary site's Config rules

enable_config_rules    = false   # Enable if DR needs independent monitoring
enable_config_recorder = false
# config_bucket_name   = ""      # Auto-generated if enabled
config_retention_days  = 365     # Match production if enabled

#------------------------------------------------------------------------------
# Reliability: AWS Backup (CRITICAL for DR)
#------------------------------------------------------------------------------
# Backup is essential for DR - this vault receives cross-region copies

enable_backup_plans = true

# Daily backups (local DR region backups)
backup_daily_schedule  = "cron(0 5 * * ? *)"  # 5 AM UTC daily
backup_daily_retention = 30                    # 30 days

# Weekly backups
backup_weekly_schedule  = "cron(0 5 ? * SUN *)"  # Sunday 5 AM UTC
backup_weekly_retention = 90                      # 90 days

# Monthly backups (archive)
enable_monthly_backup     = true
backup_monthly_schedule   = "cron(0 5 1 * ? *)"  # 1st of month 5 AM UTC
backup_monthly_retention  = 365                   # 1 year
backup_cold_storage_days  = 90                    # Move to cold storage after 90 days

# DR region KMS key for backup encryption
# IMPORTANT: Create a KMS key in the DR region and provide its ARN
# dr_kms_key_arn = "arn:aws:kms:us-west-2:123456789012:key/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

# Advanced options
enable_continuous_backup = false  # Enable for point-in-time recovery
enable_windows_vss       = false  # Enable for Windows application-consistent backups

# Compliance (WORM) - Enable for regulatory requirements
enable_backup_vault_lock    = false
vault_lock_min_retention    = 7
vault_lock_max_retention    = 365
vault_lock_changeable_days  = 3

#------------------------------------------------------------------------------
# Cost Optimization: AWS Budgets
#------------------------------------------------------------------------------
# ENABLED - Monitor DR infrastructure costs (standby resources)

enable_budgets = true

# DR budget (typically lower than production in standby mode)
monthly_budget_amount     = 500           # Adjust based on DR sizing
budget_alert_thresholds   = [50, 80, 100] # Alert at 50%, 80%, 100%
budget_forecast_threshold = 100           # Alert if forecast exceeds budget

# Alert recipients
budget_alert_emails = [
  # "dr-team@example.com",
  # "finance@example.com"
]

# Service-specific budgets (optional)
enable_service_budgets      = false
ec2_budget_amount           = 0  # 0 = disabled
rds_budget_amount           = 0
data_transfer_budget_amount = 0

# Usage budget (optional)
enable_usage_budget   = false
ec2_usage_hours_limit = 1000

# Budget actions (use with EXTREME caution in DR!)
# Never auto-stop DR instances - manual approval only
enable_budget_actions   = false
budget_action_approval  = "MANUAL"  # Always MANUAL for DR
budget_action_threshold = 150       # Higher threshold for DR
budget_ec2_instances_to_stop = []   # Leave empty for DR
