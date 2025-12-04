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

output "container_ids" {
  description = "Map of container names to IDs"
  value       = { for k, v in azurerm_storage_container.this : k => v.id }
}

output "container_names" {
  description = "List of container names"
  value       = [for k, v in azurerm_storage_container.this : v.name]
}
