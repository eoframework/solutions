#------------------------------------------------------------------------------
# Network Configuration - Production Environment
#------------------------------------------------------------------------------

network = {
  vnet_cidr                = "10.1.0.0/16"
  appservice_subnet_cidr   = "10.1.1.0/24"
  private_endpoint_cidr    = "10.1.2.0/24"
  private_endpoint_enabled = true
}
