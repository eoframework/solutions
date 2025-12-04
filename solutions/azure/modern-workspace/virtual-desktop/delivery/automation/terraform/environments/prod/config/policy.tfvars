#------------------------------------------------------------------------------
# Policy Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 18:40:17
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

policy = {
  enable_cost_policies = true  # Enable cost management policies
  enable_operational_policies = true  # Enable operational policies
  enable_security_policies = true  # Enable Azure security policies
}
