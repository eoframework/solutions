#------------------------------------------------------------------------------
# Network Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 18:40:19
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

network = {
  enable_private_endpoints = true  # Enable private endpoints for services
  subnet_private_endpoints = "10.12.2.0/24"  # Subnet for private endpoints
  subnet_session_hosts = "10.12.1.0/24"  # Subnet for session host VMs
  vnet_cidr = "10.12.0.0/16"  # Virtual network CIDR block
}
