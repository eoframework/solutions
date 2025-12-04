#------------------------------------------------------------------------------
# Azure Monitor Module - Outputs
#------------------------------------------------------------------------------

output "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID"
  value       = azurerm_log_analytics_workspace.this.id
}

output "log_analytics_workspace_name" {
  description = "Log Analytics Workspace name"
  value       = azurerm_log_analytics_workspace.this.name
}

output "log_analytics_workspace_workspace_id" {
  description = "Log Analytics Workspace workspace ID (customer ID)"
  value       = azurerm_log_analytics_workspace.this.workspace_id
}

output "log_analytics_workspace_primary_shared_key" {
  description = "Log Analytics Workspace primary shared key"
  value       = azurerm_log_analytics_workspace.this.primary_shared_key
  sensitive   = true
}

output "application_insights_ids" {
  description = "Map of Application Insights names to IDs"
  value       = { for k, v in azurerm_application_insights.this : k => v.id }
}

output "application_insights_instrumentation_keys" {
  description = "Map of Application Insights names to instrumentation keys"
  value       = { for k, v in azurerm_application_insights.this : k => v.instrumentation_key }
  sensitive   = true
}

output "application_insights_connection_strings" {
  description = "Map of Application Insights names to connection strings"
  value       = { for k, v in azurerm_application_insights.this : k => v.connection_string }
  sensitive   = true
}

output "application_insights_app_ids" {
  description = "Map of Application Insights names to app IDs"
  value       = { for k, v in azurerm_application_insights.this : k => v.app_id }
}

output "action_group_ids" {
  description = "Map of action group names to IDs"
  value       = { for k, v in azurerm_monitor_action_group.this : k => v.id }
}

output "metric_alert_ids" {
  description = "Map of metric alert names to IDs"
  value       = { for k, v in azurerm_monitor_metric_alert.this : k => v.id }
}

output "log_alert_ids" {
  description = "Map of log alert names to IDs"
  value       = { for k, v in azurerm_monitor_scheduled_query_rules_alert_v2.this : k => v.id }
}

output "diagnostic_setting_ids" {
  description = "Map of diagnostic setting names to IDs"
  value       = { for k, v in azurerm_monitor_diagnostic_setting.this : k => v.id }
}
