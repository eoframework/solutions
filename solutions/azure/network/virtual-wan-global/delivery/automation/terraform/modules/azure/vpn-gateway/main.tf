#------------------------------------------------------------------------------
# Azure VPN Gateway Module (Virtual WAN)
#------------------------------------------------------------------------------

resource "azurerm_vpn_gateway" "main" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  virtual_hub_id      = var.virtual_hub_id

  scale_unit          = var.scale_unit
  routing_preference  = var.routing_preference

  dynamic "bgp_settings" {
    for_each = var.bgp_settings != null ? [var.bgp_settings] : []
    content {
      asn         = bgp_settings.value.asn
      peer_weight = bgp_settings.value.peer_weight

      dynamic "instance_0_bgp_peering_address" {
        for_each = bgp_settings.value.instance_0_bgp_peering_address != null ? [bgp_settings.value.instance_0_bgp_peering_address] : []
        content {
          custom_ips = instance_0_bgp_peering_address.value.custom_ips
        }
      }

      dynamic "instance_1_bgp_peering_address" {
        for_each = bgp_settings.value.instance_1_bgp_peering_address != null ? [bgp_settings.value.instance_1_bgp_peering_address] : []
        content {
          custom_ips = instance_1_bgp_peering_address.value.custom_ips
        }
      }
    }
  }

  tags = var.tags
}
