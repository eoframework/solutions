#------------------------------------------------------------------------------
# Networking Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 18:26:50
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

network = {
  enable_private_endpoints = true  # Enable private endpoints for services
  subnet_functions = "10.2.1.0/24"  # Subnet for Azure Functions
  subnet_private_endpoints = "10.2.2.0/24"  # Subnet for private endpoints
  vnet_cidr = "10.2.0.0/16"  # Virtual network CIDR block
}
