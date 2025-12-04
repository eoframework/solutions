#------------------------------------------------------------------------------
# Sentinel Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 23:05:07
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

sentinel = {
  enabled = false  # Enable Sentinel policy enforcement
  enforcement_level = "advisory"  # Default policy enforcement level
  policy_count = 10  # Target Sentinel policy count
}
