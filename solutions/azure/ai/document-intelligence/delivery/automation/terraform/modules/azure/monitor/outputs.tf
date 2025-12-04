#------------------------------------------------------------------------------
# Azure Monitor Module - Outputs
#------------------------------------------------------------------------------

output "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID"
  value       = var.create_log_analytics ? azurerm_log_analytics_workspace.this[0].id : var.log_analytics_workspace_id
}

output "log_analytics_workspace_name" {
  description = "Log Analytics workspace name"
  value       = var.create_log_analytics ? azurerm_log_analytics_workspace.this[0].name : null
}

output "log_analytics_primary_key" {
  description = "Log Analytics primary shared key"
  value       = var.create_log_analytics ? azurerm_log_analytics_workspace.this[0].primary_shared_key : null
  sensitive   = true
}

output "log_analytics_secondary_key" {
  description = "Log Analytics secondary shared key"
  value       = var.create_log_analytics ? azurerm_log_analytics_workspace.this[0].secondary_shared_key : null
  sensitive   = true
}

output "app_insights_id" {
  description = "Application Insights ID"
  value       = var.create_app_insights ? azurerm_application_insights.this[0].id : null
}

output "app_insights_app_id" {
  description = "Application Insights app ID"
  value       = var.create_app_insights ? azurerm_application_insights.this[0].app_id : null
}

output "app_insights_instrumentation_key" {
  description = "Application Insights instrumentation key"
  value       = var.create_app_insights ? azurerm_application_insights.this[0].instrumentation_key : null
  sensitive   = true
}

output "app_insights_connection_string" {
  description = "Application Insights connection string"
  value       = var.create_app_insights ? azurerm_application_insights.this[0].connection_string : null
  sensitive   = true
}

output "action_group_id" {
  description = "Action group ID"
  value       = var.create_action_group ? azurerm_monitor_action_group.this[0].id : null
}

output "dashboard_id" {
  description = "Dashboard ID"
  value       = var.create_dashboard ? azurerm_portal_dashboard.this[0].id : null
}
