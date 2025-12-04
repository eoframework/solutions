#------------------------------------------------------------------------------
# Network Configuration - Production Environment
#------------------------------------------------------------------------------

network = {
  vnet_cidr                = "10.10.0.0/16"
  session_hosts_cidr       = "10.10.1.0/24"
  private_endpoint_cidr    = "10.10.2.0/24"
  private_endpoint_enabled = true
}
