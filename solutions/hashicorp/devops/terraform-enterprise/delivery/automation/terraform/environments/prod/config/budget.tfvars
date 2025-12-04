#------------------------------------------------------------------------------
# Budget Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 23:05:07
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

budget = {
  alert_thresholds = "[50, 80, 100]"  # TODO: Replace with actual value  # Budget alert threshold percentages
  enabled = true  # Enable AWS Budgets
  monthly_amount = 5000  # Monthly budget limit (USD)
}
