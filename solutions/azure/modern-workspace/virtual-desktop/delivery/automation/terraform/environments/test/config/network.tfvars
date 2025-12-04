#------------------------------------------------------------------------------
# Network Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 18:40:18
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

network = {
  enable_private_endpoints = false  # Enable private endpoints for services
  subnet_private_endpoints = "10.11.2.0/24"  # Subnet for private endpoints
  subnet_session_hosts = "10.11.1.0/24"  # Subnet for session host VMs
  vnet_cidr = "10.11.0.0/16"  # Virtual network CIDR block
}
