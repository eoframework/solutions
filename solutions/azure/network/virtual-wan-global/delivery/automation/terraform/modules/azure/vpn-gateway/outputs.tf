#------------------------------------------------------------------------------
# Azure VPN Gateway Module Outputs
#------------------------------------------------------------------------------

output "id" {
  description = "ID of the VPN Gateway"
  value       = azurerm_vpn_gateway.main.id
}

output "name" {
  description = "Name of the VPN Gateway"
  value       = azurerm_vpn_gateway.main.name
}

output "bgp_settings" {
  description = "BGP settings of the VPN Gateway"
  value       = azurerm_vpn_gateway.main.bgp_settings
}
