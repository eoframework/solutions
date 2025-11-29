#------------------------------------------------------------------------------
# AWS Well-Architected Framework Configuration - TEST ENVIRONMENT
#------------------------------------------------------------------------------
# Minimal governance for test environments:
# - Most features DISABLED to reduce costs and complexity
# - Only budget alerts enabled by default for cost visibility
# - Enable specific features as needed for testing
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Operational Excellence: AWS Config Rules
#------------------------------------------------------------------------------
# DISABLED by default - enable only if testing compliance features

enable_config_rules         = false
enable_config_recorder      = false
# config_bucket_name        = ""      # Auto-generated if enabled
config_retention_days       = 90      # Minimum retention if enabled
enable_config_security_rules = false

#------------------------------------------------------------------------------
# Reliability: AWS Backup
#------------------------------------------------------------------------------
# DISABLED by default - test data is ephemeral

enable_backup_plans = false

# If enabled, minimal configuration:
backup_daily_schedule  = "cron(0 5 * * ? *)"  # 5 AM UTC daily
backup_daily_retention = 7                     # 7 days only

#------------------------------------------------------------------------------
# Cost Optimization: AWS Budgets
#------------------------------------------------------------------------------
# ENABLED by default - helps catch runaway test costs!

enable_budgets = true

# Low budget for test environment
monthly_budget_amount     = 100           # Low threshold for test
budget_alert_thresholds   = [50, 80, 100] # Alert at 50%, 80%, 100%
budget_forecast_threshold = 100           # Alert if forecast exceeds budget

# Alert recipients - add your team email
budget_alert_emails = [
  # "team@example.com"
]
