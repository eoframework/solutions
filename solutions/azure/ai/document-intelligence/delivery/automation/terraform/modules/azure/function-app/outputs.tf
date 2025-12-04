#------------------------------------------------------------------------------
# Azure Function App Module - Outputs
#------------------------------------------------------------------------------

output "id" {
  description = "Function app ID"
  value       = azurerm_linux_function_app.this.id
}

output "name" {
  description = "Function app name"
  value       = azurerm_linux_function_app.this.name
}

output "default_hostname" {
  description = "Default hostname"
  value       = azurerm_linux_function_app.this.default_hostname
}

output "outbound_ip_addresses" {
  description = "Outbound IP addresses"
  value       = azurerm_linux_function_app.this.outbound_ip_addresses
}

output "possible_outbound_ip_addresses" {
  description = "Possible outbound IP addresses"
  value       = azurerm_linux_function_app.this.possible_outbound_ip_addresses
}

output "identity" {
  description = "Identity block"
  value       = azurerm_linux_function_app.this.identity
}

output "principal_id" {
  description = "System-assigned managed identity principal ID"
  value       = try(azurerm_linux_function_app.this.identity[0].principal_id, null)
}

output "tenant_id" {
  description = "System-assigned managed identity tenant ID"
  value       = try(azurerm_linux_function_app.this.identity[0].tenant_id, null)
}

output "service_plan_id" {
  description = "Service plan ID"
  value       = var.create_service_plan ? azurerm_service_plan.this[0].id : var.service_plan_id
}
