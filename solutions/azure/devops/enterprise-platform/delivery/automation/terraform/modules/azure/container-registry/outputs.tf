#------------------------------------------------------------------------------
# Azure Container Registry Module - Outputs
#------------------------------------------------------------------------------

output "id" {
  description = "Container Registry ID"
  value       = azurerm_container_registry.this.id
}

output "name" {
  description = "Container Registry name"
  value       = azurerm_container_registry.this.name
}

output "login_server" {
  description = "Container Registry login server"
  value       = azurerm_container_registry.this.login_server
}

output "admin_username" {
  description = "Admin username"
  value       = var.admin_enabled ? azurerm_container_registry.this.admin_username : null
}

output "admin_password" {
  description = "Admin password"
  value       = var.admin_enabled ? azurerm_container_registry.this.admin_password : null
  sensitive   = true
}

output "identity_principal_id" {
  description = "Identity principal ID"
  value       = var.identity_type != null ? azurerm_container_registry.this.identity[0].principal_id : null
}

output "identity_tenant_id" {
  description = "Identity tenant ID"
  value       = var.identity_type != null ? azurerm_container_registry.this.identity[0].tenant_id : null
}

output "webhook_ids" {
  description = "Map of webhook names to IDs"
  value       = { for k, v in azurerm_container_registry_webhook.this : k => v.id }
}

output "scope_map_ids" {
  description = "Map of scope map names to IDs"
  value       = { for k, v in azurerm_container_registry_scope_map.this : k => v.id }
}

output "token_ids" {
  description = "Map of token names to IDs"
  value       = { for k, v in azurerm_container_registry_token.this : k => v.id }
}
