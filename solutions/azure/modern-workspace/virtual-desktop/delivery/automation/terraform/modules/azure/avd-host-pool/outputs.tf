#------------------------------------------------------------------------------
# Azure Virtual Desktop Host Pool Module - Outputs
#------------------------------------------------------------------------------

output "id" {
  description = "Host pool ID"
  value       = azurerm_virtual_desktop_host_pool.this.id
}

output "name" {
  description = "Host pool name"
  value       = azurerm_virtual_desktop_host_pool.this.name
}

output "registration_token" {
  description = "Host pool registration token"
  value       = azurerm_virtual_desktop_host_pool_registration_info.this.token
  sensitive   = true
}

output "registration_expiration" {
  description = "Registration token expiration date"
  value       = azurerm_virtual_desktop_host_pool_registration_info.this.expiration_date
}
