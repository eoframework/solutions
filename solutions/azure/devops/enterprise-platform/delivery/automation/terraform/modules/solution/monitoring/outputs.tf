#------------------------------------------------------------------------------
# Monitoring Module - Outputs
#------------------------------------------------------------------------------

output "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID"
  value       = module.monitor.log_analytics_workspace_id
}

output "log_analytics_workspace_name" {
  description = "Log Analytics Workspace name"
  value       = module.monitor.log_analytics_workspace_name
}

output "application_insights_id" {
  description = "Application Insights ID"
  value       = module.monitor.application_insights_ids["${var.name_prefix}-appi"]
}

output "application_insights_instrumentation_key" {
  description = "Application Insights instrumentation key"
  value       = module.monitor.application_insights_instrumentation_keys["${var.name_prefix}-appi"]
  sensitive   = true
}

output "application_insights_connection_string" {
  description = "Application Insights connection string"
  value       = module.monitor.application_insights_connection_strings["${var.name_prefix}-appi"]
  sensitive   = true
}

output "action_group_id" {
  description = "Action Group ID"
  value       = module.monitor.action_group_ids["${var.name_prefix}-alerts"]
}
