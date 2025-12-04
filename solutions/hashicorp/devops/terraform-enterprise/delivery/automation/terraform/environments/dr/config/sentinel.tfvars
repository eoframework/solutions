#------------------------------------------------------------------------------
# Sentinel Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 23:05:08
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

sentinel = {
  enabled = true  # Enable Sentinel policy enforcement
  enforcement_level = "hard-mandatory"  # Default policy enforcement level
  policy_count = 40  # Target Sentinel policy count
}
