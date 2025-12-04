#------------------------------------------------------------------------------
# Budget Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 18:41:35
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

budget = {
  alert_thresholds = [80, 100]  # Alert thresholds as percentages
  enabled = true  # Enable cost budgets
  monthly_amount = 3000  # Monthly budget in USD
  notification_email = "dev-team@company.com"  # Email for budget alerts
}
