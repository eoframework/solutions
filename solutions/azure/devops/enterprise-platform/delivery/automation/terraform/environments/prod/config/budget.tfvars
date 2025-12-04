#------------------------------------------------------------------------------
# Budget Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 18:41:34
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

budget = {
  alert_thresholds = [50, 80, 100]  # Alert thresholds as percentages
  enabled = true  # Enable cost budgets
  monthly_amount = 10000  # Monthly budget in USD
  notification_email = "finance@company.com"  # Email for budget alerts
}
