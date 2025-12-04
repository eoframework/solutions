#------------------------------------------------------------------------------
# Monitoring Module Outputs
#------------------------------------------------------------------------------

output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace"
  value       = module.monitor.id
}

output "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace"
  value       = module.monitor.name
}

output "application_insights_id" {
  description = "ID of Application Insights"
  value       = module.monitor.application_insights_id
}

output "application_insights_connection_string" {
  description = "Connection string for Application Insights"
  value       = module.monitor.application_insights_instrumentation_key
  sensitive   = true
}

output "application_insights_instrumentation_key" {
  description = "Instrumentation key for Application Insights"
  value       = module.monitor.application_insights_instrumentation_key
  sensitive   = true
}

output "action_group_id" {
  description = "ID of the monitor action group"
  value       = var.monitoring.enable_alerts ? module.monitor.action_group_ids["main"] : null
}
