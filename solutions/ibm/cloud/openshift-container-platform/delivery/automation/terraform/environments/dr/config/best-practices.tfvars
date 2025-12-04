#------------------------------------------------------------------------------
# Best Practices Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-04 00:34:06
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

budget = {
  # [Cost Optimization] Budget alert thresholds (%)
  alert_thresholds = "[50, 80, 100]"  # TODO: Replace with actual value
  # [Cost Optimization] Enable budget tracking
  enabled = true
  # [Cost Optimization] Monthly budget limit in USD
  monthly_amount_usd = 50000
}
