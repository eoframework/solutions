# Azure AI Document Intelligence - Terraform Outputs

output "resource_group_name" {
  description = "Name of the created resource group"
  value       = azurerm_resource_group.doc_intelligence.name
}

output "cognitive_services_name" {
  description = "Name of the Cognitive Services account"
  value       = azurerm_cognitive_account.document_intelligence.name
}

output "cognitive_services_endpoint" {
  description = "Endpoint of the Cognitive Services account"
  value       = azurerm_cognitive_account.document_intelligence.endpoint
}

output "cognitive_services_key" {
  description = "Primary key for Cognitive Services"
  value       = azurerm_cognitive_account.document_intelligence.primary_access_key
  sensitive   = true
}

output "storage_account_name" {
  description = "Name of the storage account"
  value       = azurerm_storage_account.document_storage.name
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = var.create_key_vault ? azurerm_key_vault.doc_intelligence[0].vault_uri : null
}