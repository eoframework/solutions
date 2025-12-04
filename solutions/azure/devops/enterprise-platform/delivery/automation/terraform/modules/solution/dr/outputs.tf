#------------------------------------------------------------------------------
# Disaster Recovery Module - Outputs
#------------------------------------------------------------------------------

output "dr_resource_group_name" {
  description = "DR resource group name"
  value       = azurerm_resource_group.dr.name
}

output "dr_resource_group_id" {
  description = "DR resource group ID"
  value       = azurerm_resource_group.dr.id
}

output "app_service_name" {
  description = "DR App Service name"
  value       = azurerm_linux_web_app.dr.name
}

output "app_service_id" {
  description = "DR App Service ID"
  value       = azurerm_linux_web_app.dr.id
}

output "app_service_url" {
  description = "DR App Service URL"
  value       = "https://${azurerm_linux_web_app.dr.default_hostname}"
}
