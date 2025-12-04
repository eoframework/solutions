#------------------------------------------------------------------------------
# Virtual WAN Core Infrastructure Module Outputs
#------------------------------------------------------------------------------

output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_id" {
  description = "ID of the resource group"
  value       = azurerm_resource_group.main.id
}

output "virtual_wan_id" {
  description = "ID of the Virtual WAN"
  value       = module.virtual_wan.id
}

output "virtual_wan_name" {
  description = "Name of the Virtual WAN"
  value       = module.virtual_wan.name
}

output "primary_hub_id" {
  description = "ID of the primary Virtual Hub"
  value       = module.primary_hub.id
}

output "primary_hub_name" {
  description = "Name of the primary Virtual Hub"
  value       = module.primary_hub.name
}

output "secondary_hub_id" {
  description = "ID of the secondary Virtual Hub"
  value       = var.enable_secondary_hub ? module.secondary_hub[0].id : null
}

output "secondary_hub_name" {
  description = "Name of the secondary Virtual Hub"
  value       = var.enable_secondary_hub ? module.secondary_hub[0].name : null
}

output "primary_hub_route_table_id" {
  description = "ID of the primary hub route table"
  value       = module.primary_hub.route_table_id
}

output "secondary_hub_route_table_id" {
  description = "ID of the secondary hub route table"
  value       = var.enable_secondary_hub ? module.secondary_hub[0].route_table_id : null
}
