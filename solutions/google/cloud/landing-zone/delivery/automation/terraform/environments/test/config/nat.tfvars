#------------------------------------------------------------------------------
# Nat Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 22:21:03
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

nat = {
  cloud_router_asn = 64514  # Cloud Router ASN for BGP
  enabled = true  # Enable Cloud NAT
  gateway_count = 1  # Number of NAT gateways per region
  logging_enabled = false  # Enable NAT logging
  min_ports_per_vm = 32  # Minimum ports per VM
}
