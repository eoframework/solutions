#------------------------------------------------------------------------------
# Best Practices Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 18:26:48
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

backup = {
  enabled = true  # Enable backup services
  retention_days = 30  # Backup retention in days
}

budget = {
  alert_thresholds = [50, 80, 100]  # Alert thresholds as percentages
  enabled = true  # Enable cost budgets
  monthly_amount = 2000  # Monthly budget in USD
  notification_email = "finance@company.com"  # Email for budget alerts
}

policy = {
  enable_cost_policies = true  # Enable cost management policies
  enable_operational_policies = true  # Enable operational policies
  enable_security_policies = true  # Enable Azure security policies
}
