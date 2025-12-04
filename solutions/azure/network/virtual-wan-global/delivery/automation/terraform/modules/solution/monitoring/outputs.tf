#------------------------------------------------------------------------------
# Virtual WAN Monitoring Module Outputs
#------------------------------------------------------------------------------

output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.main.id
}

output "log_analytics_workspace_name" {
  description = "Name of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.main.name
}

output "log_analytics_workspace_key" {
  description = "Primary shared key of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.main.primary_shared_key
  sensitive   = true
}

output "action_group_id" {
  description = "ID of the Action Group"
  value       = var.enable_alerts ? azurerm_monitor_action_group.main[0].id : null
}

output "network_watcher_primary_id" {
  description = "ID of the primary Network Watcher"
  value       = var.enable_network_watcher ? azurerm_network_watcher.primary[0].id : null
}

output "network_watcher_secondary_id" {
  description = "ID of the secondary Network Watcher"
  value       = var.enable_network_watcher && var.secondary_location != null ? azurerm_network_watcher.secondary[0].id : null
}
