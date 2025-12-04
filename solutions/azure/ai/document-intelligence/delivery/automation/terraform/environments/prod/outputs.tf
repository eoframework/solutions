#------------------------------------------------------------------------------
# Azure Document Intelligence - Production Environment Outputs
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Core Infrastructure
#------------------------------------------------------------------------------
output "resource_group_name" {
  description = "Name of the resource group"
  value       = module.core.resource_group_name
}

output "resource_group_id" {
  description = "ID of the resource group"
  value       = module.core.resource_group_id
}

output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = module.core.key_vault_name
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = module.core.key_vault_uri
}

#------------------------------------------------------------------------------
# Network
#------------------------------------------------------------------------------
output "vnet_id" {
  description = "ID of the virtual network"
  value       = module.core.vnet_id
}

output "vnet_name" {
  description = "Name of the virtual network"
  value       = module.core.vnet_name
}

#------------------------------------------------------------------------------
# Storage
#------------------------------------------------------------------------------
output "storage_account_name" {
  description = "Name of the storage account"
  value       = module.storage.storage_account_name
}

output "storage_account_primary_endpoint" {
  description = "Primary blob endpoint of the storage account"
  value       = module.storage.storage_primary_blob_endpoint
}

output "cosmos_endpoint" {
  description = "Cosmos DB account endpoint"
  value       = module.storage.cosmos_endpoint
}

output "cosmos_database_name" {
  description = "Cosmos DB database name"
  value       = module.storage.cosmos_database_name
}

#------------------------------------------------------------------------------
# Processing
#------------------------------------------------------------------------------
output "function_app_name" {
  description = "Name of the Function App"
  value       = module.processing.function_app_name
}

output "function_app_url" {
  description = "URL of the Function App"
  value       = module.processing.function_app_url
}

output "document_intelligence_endpoint" {
  description = "Azure Document Intelligence endpoint"
  value       = module.processing.document_intelligence_endpoint
}

output "logic_app_url" {
  description = "Logic App workflow URL"
  value       = module.processing.logic_app_url
}

#------------------------------------------------------------------------------
# Monitoring
#------------------------------------------------------------------------------
output "application_insights_connection_string" {
  description = "Application Insights connection string"
  value       = module.processing.application_insights_connection_string
  sensitive   = true
}

output "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID"
  value       = module.monitoring.log_analytics_workspace_id
}

#------------------------------------------------------------------------------
# Disaster Recovery
#------------------------------------------------------------------------------
output "dr_region" {
  description = "DR region location"
  value       = var.dr.enabled ? var.azure.dr_region : null
}

output "dr_storage_account_name" {
  description = "DR storage account name"
  value       = var.dr.enabled ? module.dr[0].storage_account_name : null
}

#------------------------------------------------------------------------------
# Environment Summary
#------------------------------------------------------------------------------
output "environment_summary" {
  description = "Summary of the deployed environment"
  value = {
    environment     = local.environment
    region          = var.azure.region
    dr_enabled      = var.dr.enabled
    private_endpoints = var.network.enable_private_endpoints
    function_sku    = var.compute.function_plan_sku
    cosmos_tier     = var.database.cosmos_offer_type
  }
}
