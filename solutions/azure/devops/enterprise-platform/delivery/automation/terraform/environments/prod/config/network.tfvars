#------------------------------------------------------------------------------
# Network Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 18:41:34
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

network = {
  enable_private_endpoints = true  # Enable private endpoints for services
  subnet_agents = "10.0.3.0/24"  # Subnet for self-hosted agents
  subnet_aks = "10.0.1.0/23"  # Subnet for AKS cluster
  vnet_cidr = "10.0.0.0/16"  # Virtual network CIDR block
}
