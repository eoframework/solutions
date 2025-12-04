#------------------------------------------------------------------------------
# Azure Document Intelligence Module - Outputs
#------------------------------------------------------------------------------

output "id" {
  description = "Cognitive account ID"
  value       = azurerm_cognitive_account.this.id
}

output "name" {
  description = "Cognitive account name"
  value       = azurerm_cognitive_account.this.name
}

output "endpoint" {
  description = "Cognitive account endpoint"
  value       = azurerm_cognitive_account.this.endpoint
}

output "primary_access_key" {
  description = "Primary access key"
  value       = azurerm_cognitive_account.this.primary_access_key
  sensitive   = true
}

output "secondary_access_key" {
  description = "Secondary access key"
  value       = azurerm_cognitive_account.this.secondary_access_key
  sensitive   = true
}

output "identity" {
  description = "Identity block"
  value       = azurerm_cognitive_account.this.identity
}

output "principal_id" {
  description = "System-assigned identity principal ID"
  value       = try(azurerm_cognitive_account.this.identity[0].principal_id, null)
}
