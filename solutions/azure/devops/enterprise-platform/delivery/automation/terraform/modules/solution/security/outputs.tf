#------------------------------------------------------------------------------
# Security Module - Outputs
#------------------------------------------------------------------------------

output "managed_identity_id" {
  description = "Managed identity ID"
  value       = azurerm_user_assigned_identity.main.id
}

output "managed_identity_principal_id" {
  description = "Managed identity principal ID"
  value       = azurerm_user_assigned_identity.main.principal_id
}

output "managed_identity_client_id" {
  description = "Managed identity client ID"
  value       = azurerm_user_assigned_identity.main.client_id
}

output "encryption_key_id" {
  description = "Encryption key ID"
  value       = var.security.enable_customer_managed_key ? azurerm_key_vault_key.encryption[0].id : null
}
