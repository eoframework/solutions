# Azure Sentinel SIEM - Terraform Outputs
# Output values for Azure Sentinel deployment

# Resource Group Outputs
output "resource_group_name" {
  description = "Name of the created resource group"
  value       = azurerm_resource_group.sentinel.name
}

output "resource_group_location" {
  description = "Location of the resource group"
  value       = azurerm_resource_group.sentinel.location
}

output "resource_group_id" {
  description = "ID of the resource group"
  value       = azurerm_resource_group.sentinel.id
}

# Log Analytics Workspace Outputs
output "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.sentinel.name
}

output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.sentinel.id
}

output "log_analytics_workspace_customer_id" {
  description = "Customer ID of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.sentinel.workspace_id
  sensitive   = true
}

output "log_analytics_primary_shared_key" {
  description = "Primary shared key for Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.sentinel.primary_shared_key
  sensitive   = true
}

output "log_analytics_secondary_shared_key" {
  description = "Secondary shared key for Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.sentinel.secondary_shared_key
  sensitive   = true
}

# Azure Sentinel Outputs
output "sentinel_workspace_id" {
  description = "ID of the Azure Sentinel workspace"
  value       = azurerm_sentinel_log_analytics_workspace_onboarding.sentinel.workspace_id
}

# Key Vault Outputs
output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = var.create_key_vault ? azurerm_key_vault.sentinel[0].name : null
}

output "key_vault_id" {
  description = "ID of the Key Vault"
  value       = var.create_key_vault ? azurerm_key_vault.sentinel[0].id : null
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = var.create_key_vault ? azurerm_key_vault.sentinel[0].vault_uri : null
}

# Storage Account Outputs
output "storage_account_name" {
  description = "Name of the storage account"
  value       = var.create_storage_account ? azurerm_storage_account.sentinel[0].name : null
}

output "storage_account_id" {
  description = "ID of the storage account"
  value       = var.create_storage_account ? azurerm_storage_account.sentinel[0].id : null
}

output "storage_account_primary_endpoint" {
  description = "Primary blob endpoint of the storage account"
  value       = var.create_storage_account ? azurerm_storage_account.sentinel[0].primary_blob_endpoint : null
}

output "storage_account_primary_access_key" {
  description = "Primary access key of the storage account"
  value       = var.create_storage_account ? azurerm_storage_account.sentinel[0].primary_access_key : null
  sensitive   = true
}

# Data Connector Outputs
output "data_connectors_enabled" {
  description = "List of enabled data connectors"
  value = {
    azure_active_directory = var.enable_aad_connector
    azure_security_center  = var.enable_asc_connector
    office_365             = var.enable_office365_connector
  }
}

# Networking Outputs
output "workspace_resource_id" {
  description = "Full resource ID of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.sentinel.id
}

# Configuration Outputs
output "deployment_configuration" {
  description = "Summary of deployment configuration"
  value = {
    location                    = var.location
    sku                        = var.log_analytics_sku
    retention_days             = var.log_analytics_retention_days
    daily_quota_gb             = var.log_analytics_daily_quota_gb
    customer_managed_key       = var.customer_managed_key_enabled
    internet_ingestion_enabled = var.internet_ingestion_enabled
    internet_query_enabled     = var.internet_query_enabled
  }
}

# Portal Links
output "azure_sentinel_portal_url" {
  description = "Direct link to Azure Sentinel in the Azure portal"
  value       = "https://portal.azure.com/#asset/Microsoft_Azure_Security_Insights/MainMenuBlade/0/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${azurerm_resource_group.sentinel.name}/providers/Microsoft.OperationalInsights/workspaces/${azurerm_log_analytics_workspace.sentinel.name}"
}

output "log_analytics_portal_url" {
  description = "Direct link to Log Analytics workspace in the Azure portal"
  value       = "https://portal.azure.com/#@${data.azurerm_client_config.current.tenant_id}/resource/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${azurerm_resource_group.sentinel.name}/providers/Microsoft.OperationalInsights/workspaces/${azurerm_log_analytics_workspace.sentinel.name}/overview"
}

# Connection Information
output "connection_info" {
  description = "Connection information for applications and scripts"
  value = {
    workspace_id = azurerm_log_analytics_workspace.sentinel.workspace_id
    tenant_id    = data.azurerm_client_config.current.tenant_id
    subscription_id = data.azurerm_subscription.current.subscription_id
  }
  sensitive = true
}

# Resource Tags
output "applied_tags" {
  description = "Tags applied to the resources"
  value       = var.tags
}