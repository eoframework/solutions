#------------------------------------------------------------------------------
# Nat Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 22:21:04
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

nat = {
  cloud_router_asn = 64514  # Cloud Router ASN for BGP
  enabled = true  # Enable Cloud NAT
  gateway_count = 3  # Number of NAT gateways per region
  logging_enabled = true  # Enable NAT logging
  min_ports_per_vm = 64  # Minimum ports per VM
}
