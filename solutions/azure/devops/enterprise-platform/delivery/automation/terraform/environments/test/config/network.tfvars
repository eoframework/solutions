#------------------------------------------------------------------------------
# Network Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 18:41:35
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

network = {
  enable_private_endpoints = false  # Enable private endpoints for services
  subnet_agents = "10.1.3.0/24"  # Subnet for self-hosted agents
  subnet_aks = "10.1.1.0/23"  # Subnet for AKS cluster
  vnet_cidr = "10.1.0.0/16"  # Virtual network CIDR block
}
