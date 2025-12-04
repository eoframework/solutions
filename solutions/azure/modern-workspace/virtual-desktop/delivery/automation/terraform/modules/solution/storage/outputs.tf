#------------------------------------------------------------------------------
# Storage Module Outputs
#------------------------------------------------------------------------------

output "storage_account_id" {
  description = "ID of the FSLogix storage account"
  value       = azurerm_storage_account.fslogix.id
}

output "storage_account_name" {
  description = "Name of the FSLogix storage account"
  value       = azurerm_storage_account.fslogix.name
}

output "fslogix_share_name" {
  description = "Name of the FSLogix file share"
  value       = azurerm_storage_share.fslogix.name
}

output "fslogix_share_url" {
  description = "URL of the FSLogix file share"
  value       = "\\\\${azurerm_storage_account.fslogix.name}.file.core.windows.net\\${azurerm_storage_share.fslogix.name}"
}

output "storage_account_primary_endpoint" {
  description = "Primary file endpoint of the storage account"
  value       = azurerm_storage_account.fslogix.primary_file_endpoint
}
