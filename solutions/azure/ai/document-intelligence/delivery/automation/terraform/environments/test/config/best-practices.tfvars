#------------------------------------------------------------------------------
# Best Practices Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 18:26:49
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

backup = {
  enabled = false  # Enable backup services
  retention_days = 7  # Backup retention in days
}

budget = {
  alert_thresholds = [80, 100]  # Alert thresholds as percentages
  enabled = true  # Enable cost budgets
  monthly_amount = 500  # Monthly budget in USD
  notification_email = "dev-team@company.com"  # Email for budget alerts
}

policy = {
  enable_cost_policies = true  # Enable cost management policies
  enable_operational_policies = false  # Enable operational policies
  enable_security_policies = false  # Enable Azure security policies
}
