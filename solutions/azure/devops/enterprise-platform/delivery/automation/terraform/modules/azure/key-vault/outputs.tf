#------------------------------------------------------------------------------
# Azure Key Vault Module - Outputs
#------------------------------------------------------------------------------

output "id" {
  description = "Key Vault ID"
  value       = azurerm_key_vault.this.id
}

output "name" {
  description = "Key Vault name"
  value       = azurerm_key_vault.this.name
}

output "vault_uri" {
  description = "Key Vault URI"
  value       = azurerm_key_vault.this.vault_uri
}

output "key_ids" {
  description = "Map of key names to IDs"
  value       = { for k, v in azurerm_key_vault_key.this : k => v.id }
}

output "key_resource_ids" {
  description = "Map of key names to resource IDs"
  value       = { for k, v in azurerm_key_vault_key.this : k => v.resource_id }
}

output "key_versionless_ids" {
  description = "Map of key names to versionless IDs"
  value       = { for k, v in azurerm_key_vault_key.this : k => v.versionless_id }
}

output "secret_ids" {
  description = "Map of secret names to IDs"
  value       = { for k, v in azurerm_key_vault_secret.this : k => v.id }
}

output "secret_versionless_ids" {
  description = "Map of secret names to versionless IDs"
  value       = { for k, v in azurerm_key_vault_secret.this : k => v.versionless_id }
}
