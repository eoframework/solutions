#------------------------------------------------------------------------------
# Budget Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 18:41:38
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

budget = {
  alert_thresholds = [50, 80, 100]  # Alert thresholds as percentages
  enabled = true  # Enable cost budgets
  monthly_amount = 5000  # Monthly budget in USD
  notification_email = "finance@company.com"  # Email for budget alerts
}
