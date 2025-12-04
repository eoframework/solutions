#------------------------------------------------------------------------------
# Budget Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 18:40:19
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

budget = {
  alert_thresholds = [50, 80, 100]  # Alert thresholds as percentages
  enabled = true  # Enable cost budgets
  monthly_amount = 3000  # Monthly budget in USD
  notification_email = "finance@company.com"  # Email for budget alerts
}
