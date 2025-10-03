# Azure Monitoring Module - Outputs

output "resource_group_id" {
  description = "Resource group ID for monitoring resources"
  value       = azurerm_resource_group.monitoring.id
}

output "log_analytics_workspace" {
  description = "Log Analytics workspace details"
  value = {
    id           = azurerm_log_analytics_workspace.main.id
    workspace_id = azurerm_log_analytics_workspace.main.workspace_id
    name         = azurerm_log_analytics_workspace.main.name
  }
}

output "application_insights" {
  description = "Application Insights details"
  value = {
    id                  = azurerm_application_insights.main.id
    instrumentation_key = azurerm_application_insights.main.instrumentation_key
    connection_string   = azurerm_application_insights.main.connection_string
    app_id             = azurerm_application_insights.main.app_id
  }
  sensitive = true
}

output "action_group_id" {
  description = "Action group ID for alerts"
  value       = azurerm_monitor_action_group.main.id
}

output "metric_alerts" {
  description = "Metric alerts created"
  value = {
    cpu_high    = azurerm_monitor_metric_alert.cpu_high.id
    memory_high = azurerm_monitor_metric_alert.memory_high.id
  }
}

output "activity_log_alert" {
  description = "Activity log alert ID"
  value       = azurerm_monitor_activity_log_alert.resource_health.id
}