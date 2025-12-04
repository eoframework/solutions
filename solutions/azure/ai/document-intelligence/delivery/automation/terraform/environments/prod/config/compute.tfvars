#------------------------------------------------------------------------------
# Compute Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 18:26:48
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

compute = {
  autoscale_max_instances = 10  # Maximum Function instances
  autoscale_min_instances = 1  # Minimum Function instances
  function_plan_sku = "EP1"  # Function plan SKU
  function_plan_type = "Premium"  # Function App hosting plan type
}
