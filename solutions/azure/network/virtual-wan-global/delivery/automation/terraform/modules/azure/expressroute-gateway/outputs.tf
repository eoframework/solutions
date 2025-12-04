#------------------------------------------------------------------------------
# Azure ExpressRoute Gateway Module Outputs
#------------------------------------------------------------------------------

output "id" {
  description = "ID of the ExpressRoute Gateway"
  value       = azurerm_express_route_gateway.main.id
}

output "name" {
  description = "Name of the ExpressRoute Gateway"
  value       = azurerm_express_route_gateway.main.name
}
