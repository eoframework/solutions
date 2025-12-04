#------------------------------------------------------------------------------
# Azure App Service Module - Outputs
#------------------------------------------------------------------------------

output "service_plan_id" {
  description = "App Service Plan ID"
  value       = azurerm_service_plan.this.id
}

output "service_plan_name" {
  description = "App Service Plan name"
  value       = azurerm_service_plan.this.name
}

output "app_service_id" {
  description = "App Service ID"
  value       = var.os_type == "Linux" ? azurerm_linux_web_app.this[0].id : azurerm_windows_web_app.this[0].id
}

output "app_service_name" {
  description = "App Service name"
  value       = var.os_type == "Linux" ? azurerm_linux_web_app.this[0].name : azurerm_windows_web_app.this[0].name
}

output "app_service_default_hostname" {
  description = "App Service default hostname"
  value       = var.os_type == "Linux" ? azurerm_linux_web_app.this[0].default_hostname : azurerm_windows_web_app.this[0].default_hostname
}

output "app_service_url" {
  description = "App Service URL"
  value       = var.os_type == "Linux" ? "https://${azurerm_linux_web_app.this[0].default_hostname}" : "https://${azurerm_windows_web_app.this[0].default_hostname}"
}

output "app_service_identity_principal_id" {
  description = "App Service identity principal ID"
  value       = var.identity_type != null ? (var.os_type == "Linux" ? azurerm_linux_web_app.this[0].identity[0].principal_id : azurerm_windows_web_app.this[0].identity[0].principal_id) : null
}

output "app_service_identity_tenant_id" {
  description = "App Service identity tenant ID"
  value       = var.identity_type != null ? (var.os_type == "Linux" ? azurerm_linux_web_app.this[0].identity[0].tenant_id : azurerm_windows_web_app.this[0].identity[0].tenant_id) : null
}

output "deployment_slot_ids" {
  description = "Map of deployment slot names to IDs"
  value       = var.os_type == "Linux" ? { for k, v in azurerm_linux_web_app_slot.this : k => v.id } : { for k, v in azurerm_windows_web_app_slot.this : k => v.id }
}

output "deployment_slot_hostnames" {
  description = "Map of deployment slot names to hostnames"
  value       = var.os_type == "Linux" ? { for k, v in azurerm_linux_web_app_slot.this : k => v.default_hostname } : { for k, v in azurerm_windows_web_app_slot.this : k => v.default_hostname }
}
