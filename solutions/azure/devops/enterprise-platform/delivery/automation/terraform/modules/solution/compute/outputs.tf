#------------------------------------------------------------------------------
# Compute Module - Outputs
#------------------------------------------------------------------------------

output "app_service_plan_id" {
  description = "App Service Plan ID"
  value       = azurerm_service_plan.main.id
}

output "app_service_plan_name" {
  description = "App Service Plan name"
  value       = azurerm_service_plan.main.name
}

output "app_service_id" {
  description = "App Service ID"
  value       = azurerm_linux_web_app.main.id
}

output "app_service_name" {
  description = "App Service name"
  value       = azurerm_linux_web_app.main.name
}

output "app_service_url" {
  description = "App Service URL"
  value       = "https://${azurerm_linux_web_app.main.default_hostname}"
}

output "app_service_identity_principal_id" {
  description = "App Service system-assigned identity principal ID"
  value       = azurerm_linux_web_app.main.identity[0].principal_id
}

output "staging_slot_url" {
  description = "Staging slot URL"
  value       = var.app_service_config.deployment_slots_enabled ? "https://${azurerm_linux_web_app_slot.staging[0].default_hostname}" : null
}
