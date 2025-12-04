#------------------------------------------------------------------------------
# Azure Monitor Module - Outputs
#------------------------------------------------------------------------------

output "id" {
  description = "Log Analytics Workspace ID"
  value       = azurerm_log_analytics_workspace.this.id
}

output "name" {
  description = "Log Analytics Workspace name"
  value       = azurerm_log_analytics_workspace.this.name
}

output "workspace_id" {
  description = "Log Analytics Workspace ID (GUID)"
  value       = azurerm_log_analytics_workspace.this.workspace_id
}

output "primary_shared_key" {
  description = "Primary shared key"
  value       = azurerm_log_analytics_workspace.this.primary_shared_key
  sensitive   = true
}

output "application_insights_id" {
  description = "Application Insights ID"
  value       = var.create_application_insights ? azurerm_application_insights.this[0].id : null
}

output "application_insights_instrumentation_key" {
  description = "Application Insights instrumentation key"
  value       = var.create_application_insights ? azurerm_application_insights.this[0].instrumentation_key : null
  sensitive   = true
}

output "action_group_ids" {
  description = "Map of action group names to IDs"
  value       = { for k, v in azurerm_monitor_action_group.this : k => v.id }
}
