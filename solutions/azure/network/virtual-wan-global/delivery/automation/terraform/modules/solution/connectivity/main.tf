#------------------------------------------------------------------------------
# Virtual WAN Connectivity Module
# Creates: VPN Gateways, ExpressRoute Gateways in both hubs
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Primary Hub - VPN Gateway
#------------------------------------------------------------------------------
module "primary_vpn_gateway" {
  count  = var.enable_vpn_gateway ? 1 : 0
  source = "../../azure/vpn-gateway"

  name                = "${var.name_prefix}-vpngw-primary"
  resource_group_name = var.resource_group_name
  location            = var.primary_location
  virtual_hub_id      = var.primary_hub_id

  scale_unit         = var.vpn_gateway_scale_unit
  routing_preference = var.vpn_routing_preference
  bgp_settings       = var.vpn_bgp_settings

  tags = var.common_tags
}

#------------------------------------------------------------------------------
# Secondary Hub - VPN Gateway
#------------------------------------------------------------------------------
module "secondary_vpn_gateway" {
  count  = var.enable_vpn_gateway && var.enable_secondary_hub ? 1 : 0
  source = "../../azure/vpn-gateway"

  name                = "${var.name_prefix}-vpngw-secondary"
  resource_group_name = var.resource_group_name
  location            = var.secondary_location
  virtual_hub_id      = var.secondary_hub_id

  scale_unit         = var.vpn_gateway_scale_unit
  routing_preference = var.vpn_routing_preference
  bgp_settings       = var.vpn_bgp_settings_secondary

  tags = var.common_tags
}

#------------------------------------------------------------------------------
# Primary Hub - ExpressRoute Gateway
#------------------------------------------------------------------------------
module "primary_er_gateway" {
  count  = var.enable_expressroute_gateway ? 1 : 0
  source = "../../azure/expressroute-gateway"

  name                = "${var.name_prefix}-ergw-primary"
  resource_group_name = var.resource_group_name
  location            = var.primary_location
  virtual_hub_id      = var.primary_hub_id

  scale_units                   = var.er_gateway_scale_units
  allow_non_virtual_wan_traffic = var.er_allow_non_vwan_traffic

  tags = var.common_tags
}

#------------------------------------------------------------------------------
# Secondary Hub - ExpressRoute Gateway
#------------------------------------------------------------------------------
module "secondary_er_gateway" {
  count  = var.enable_expressroute_gateway && var.enable_secondary_hub ? 1 : 0
  source = "../../azure/expressroute-gateway"

  name                = "${var.name_prefix}-ergw-secondary"
  resource_group_name = var.resource_group_name
  location            = var.secondary_location
  virtual_hub_id      = var.secondary_hub_id

  scale_units                   = var.er_gateway_scale_units
  allow_non_virtual_wan_traffic = var.er_allow_non_vwan_traffic

  tags = var.common_tags
}
