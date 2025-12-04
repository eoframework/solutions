#------------------------------------------------------------------------------
# Azure Virtual Network Module - Outputs
#------------------------------------------------------------------------------

output "id" {
  description = "VNet ID"
  value       = azurerm_virtual_network.this.id
}

output "name" {
  description = "VNet name"
  value       = azurerm_virtual_network.this.name
}

output "address_space" {
  description = "VNet address space"
  value       = azurerm_virtual_network.this.address_space
}

output "subnet_ids" {
  description = "Map of subnet names to IDs"
  value       = { for k, v in azurerm_subnet.this : k => v.id }
}

output "subnet_address_prefixes" {
  description = "Map of subnet names to address prefixes"
  value       = { for k, v in azurerm_subnet.this : k => v.address_prefixes }
}

output "nsg_ids" {
  description = "Map of NSG names to IDs"
  value       = { for k, v in azurerm_network_security_group.this : k => v.id }
}
