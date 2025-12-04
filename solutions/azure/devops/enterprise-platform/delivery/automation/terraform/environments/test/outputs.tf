#------------------------------------------------------------------------------
# Azure DevOps Enterprise Platform - Production Environment Outputs
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
# Azure DevOps
#------------------------------------------------------------------------------
output "devops_project_id" {
  description = "Azure DevOps project ID"
  value       = module.devops.project_id
}

output "devops_project_name" {
  description = "Azure DevOps project name"
  value       = module.devops.project_name
}

output "devops_project_url" {
  description = "Azure DevOps project URL"
  value       = module.devops.project_url
}

output "service_connection_id" {
  description = "Azure service connection ID"
  value       = module.devops.service_connection_id
}

#------------------------------------------------------------------------------
# Compute
#------------------------------------------------------------------------------
output "app_service_name" {
  description = "Name of the App Service"
  value       = module.compute.app_service_name
}

output "app_service_url" {
  description = "URL of the App Service"
  value       = module.compute.app_service_url
}

output "app_service_plan_name" {
  description = "Name of the App Service Plan"
  value       = module.compute.app_service_plan_name
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

output "dr_app_service_name" {
  description = "DR app service name"
  value       = var.dr.enabled ? module.dr[0].app_service_name : null
}

#------------------------------------------------------------------------------
# Environment Summary
#------------------------------------------------------------------------------
output "environment_summary" {
  description = "Summary of the deployed environment"
  value = {
    environment          = local.environment
    region               = var.azure.region
    dr_enabled           = var.dr.enabled
    private_endpoints    = var.network.private_endpoint_enabled
    app_service_sku      = var.compute.app_service_plan_sku
    devops_organization  = var.devops.organization_name
    devops_project       = var.devops.project_name
  }
}
