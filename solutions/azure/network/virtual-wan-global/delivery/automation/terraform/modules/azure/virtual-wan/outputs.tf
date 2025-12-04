#------------------------------------------------------------------------------
# Azure Virtual WAN Module Outputs
#------------------------------------------------------------------------------

output "id" {
  description = "ID of the Virtual WAN"
  value       = azurerm_virtual_wan.main.id
}

output "name" {
  description = "Name of the Virtual WAN"
  value       = azurerm_virtual_wan.main.name
}
