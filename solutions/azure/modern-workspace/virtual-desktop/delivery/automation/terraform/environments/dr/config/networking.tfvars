#------------------------------------------------------------------------------
# Network Configuration - DR Environment
#------------------------------------------------------------------------------

network = {
  vnet_cidr                = "10.12.0.0/16"
  session_hosts_cidr       = "10.12.1.0/24"
  private_endpoint_cidr    = "10.12.2.0/24"
  private_endpoint_enabled = true
}
