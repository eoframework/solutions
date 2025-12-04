#------------------------------------------------------------------------------
# Azure Storage Account Module - Outputs
#------------------------------------------------------------------------------

output "id" {
  description = "Storage account ID"
  value       = azurerm_storage_account.this.id
}

output "name" {
  description = "Storage account name"
  value       = azurerm_storage_account.this.name
}

output "primary_blob_endpoint" {
  description = "Primary blob endpoint URL"
  value       = azurerm_storage_account.this.primary_blob_endpoint
}

output "primary_file_endpoint" {
  description = "Primary file endpoint URL"
  value       = azurerm_storage_account.this.primary_file_endpoint
}

output "primary_access_key" {
  description = "Primary access key"
  value       = azurerm_storage_account.this.primary_access_key
  sensitive   = true
}

output "primary_connection_string" {
  description = "Primary connection string"
  value       = azurerm_storage_account.this.primary_connection_string
  sensitive   = true
}

output "secondary_access_key" {
  description = "Secondary access key"
  value       = azurerm_storage_account.this.secondary_access_key
  sensitive   = true
}

output "file_share_ids" {
  description = "Map of file share names to IDs"
  value       = { for k, v in azurerm_storage_share.this : k => v.id }
}

output "file_share_urls" {
  description = "Map of file share names to URLs"
  value       = { for k, v in azurerm_storage_share.this : k => v.url }
}

output "container_ids" {
  description = "Map of container names to IDs"
  value       = { for k, v in azurerm_storage_container.this : k => v.id }
}
