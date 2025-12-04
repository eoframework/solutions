#------------------------------------------------------------------------------
# Budget Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 23:05:07
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

budget = {
  alert_thresholds = "[80, 100]"  # TODO: Replace with actual value  # Budget alert threshold percentages
  enabled = false  # Enable AWS Budgets
  monthly_amount = 1000  # Monthly budget limit (USD)
}
