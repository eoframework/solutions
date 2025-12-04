#------------------------------------------------------------------------------
# Best Practices Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 17:57:13
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

backup = {
  daily_retention = 7  # Daily backup retention days
  enable_vault_lock = false  # Enable backup vault lock
  enabled = false  # Enable AWS Backup
  monthly_retention = 0  # Monthly backup retention days
  weekly_retention = 0  # Weekly backup retention days
}

budget = {
  alert_thresholds = [80, 100]  # Alert thresholds %
  enabled = true  # Enable AWS Budget
  monthly_amount = 500  # Monthly budget USD
  notification_email = "finance@company.com"  # Budget alert email
}

config_rules = {
  enabled = false  # Enable AWS Config Rules
}

guardduty = {
  enabled = false  # Enable GuardDuty
}
