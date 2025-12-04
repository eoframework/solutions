#------------------------------------------------------------------------------
# Azure Virtual Desktop - Production Environment Outputs
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
  description = "Name of the FSLogix storage account"
  value       = module.storage.storage_account_name
}

output "fslogix_share_name" {
  description = "Name of the FSLogix file share"
  value       = module.storage.fslogix_share_name
}

output "fslogix_share_url" {
  description = "URL of the FSLogix file share"
  value       = module.storage.fslogix_share_url
}

#------------------------------------------------------------------------------
# AVD Resources
#------------------------------------------------------------------------------
output "host_pool_name" {
  description = "Name of the AVD host pool"
  value       = module.avd.host_pool_name
}

output "host_pool_id" {
  description = "ID of the AVD host pool"
  value       = module.avd.host_pool_id
}

output "workspace_name" {
  description = "Name of the AVD workspace"
  value       = module.avd.workspace_name
}

output "workspace_id" {
  description = "ID of the AVD workspace"
  value       = module.avd.workspace_id
}

output "desktop_app_group_name" {
  description = "Name of the desktop application group"
  value       = module.avd.desktop_app_group_name
}

output "remoteapp_app_group_name" {
  description = "Name of the RemoteApp application group"
  value       = var.app_groups.remoteapp_enabled ? module.avd.remoteapp_app_group_name : null
}

output "session_host_names" {
  description = "Names of the session host VMs"
  value       = module.avd.session_host_names
}

#------------------------------------------------------------------------------
# Monitoring
#------------------------------------------------------------------------------
output "application_insights_connection_string" {
  description = "Application Insights connection string"
  value       = module.monitoring.application_insights_connection_string
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
    environment       = local.environment
    region            = var.azure.region
    dr_enabled        = var.dr.enabled
    private_endpoints = var.network.private_endpoint_enabled
    host_pool_type    = var.avd.host_pool_type
    session_host_count = var.session_hosts.vm_count
    autoscale_enabled = var.autoscale.enabled
  }
}
