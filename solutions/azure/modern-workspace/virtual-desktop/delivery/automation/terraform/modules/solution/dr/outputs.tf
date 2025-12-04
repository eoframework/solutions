#------------------------------------------------------------------------------
# DR Module Outputs
#------------------------------------------------------------------------------

output "dr_resource_group_name" {
  description = "Name of the DR resource group"
  value       = azurerm_resource_group.dr.name
}

output "dr_resource_group_id" {
  description = "ID of the DR resource group"
  value       = azurerm_resource_group.dr.id
}

output "storage_account_name" {
  description = "Name of the DR storage account"
  value       = var.dr.replication_enabled ? azurerm_storage_account.dr[0].name : null
}

output "storage_account_id" {
  description = "ID of the DR storage account"
  value       = var.dr.replication_enabled ? azurerm_storage_account.dr[0].id : null
}
