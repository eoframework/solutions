#------------------------------------------------------------------------------
# Connectivity Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 18:36:44
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

connectivity = {
  enable_expressroute_gateway = false  # Enable ExpressRoute Gateway in hubs
  enable_vpn_gateway = true  # Enable VPN Gateway in hubs
  # Allow non-VWAN traffic through ER Gateway
  er_allow_non_vwan_traffic = false
  er_gateway_scale_units = 1  # ExpressRoute Gateway scale units
  vpn_bgp_asn = 65515  # BGP ASN for VPN Gateway
  vpn_bgp_peer_weight = 0  # BGP peer weight
  # VPN Gateway scale units (defines throughput)
  vpn_gateway_scale_unit = 1
  vpn_routing_preference = "Microsoft Network"  # VPN Gateway routing preference
}
