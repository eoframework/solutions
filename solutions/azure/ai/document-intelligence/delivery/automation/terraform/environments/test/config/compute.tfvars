#------------------------------------------------------------------------------
# Compute Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 18:26:49
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

compute = {
  autoscale_max_instances = 3  # Maximum Function instances
  autoscale_min_instances = 0  # Minimum Function instances
  function_plan_sku = "Y1"  # Function plan SKU
  function_plan_type = "Consumption"  # Function App hosting plan type
}
