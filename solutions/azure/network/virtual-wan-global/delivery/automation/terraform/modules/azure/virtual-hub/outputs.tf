#------------------------------------------------------------------------------
# Azure Virtual Hub Module Outputs
#------------------------------------------------------------------------------

output "id" {
  description = "ID of the Virtual Hub"
  value       = azurerm_virtual_hub.main.id
}

output "name" {
  description = "Name of the Virtual Hub"
  value       = azurerm_virtual_hub.main.name
}

output "route_table_id" {
  description = "ID of the Virtual Hub route table"
  value       = var.create_route_table ? azurerm_virtual_hub_route_table.main[0].id : null
}
