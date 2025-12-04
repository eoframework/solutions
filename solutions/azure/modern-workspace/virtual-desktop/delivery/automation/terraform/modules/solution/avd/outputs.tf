#------------------------------------------------------------------------------
# AVD Module Outputs
#------------------------------------------------------------------------------

output "host_pool_id" {
  description = "ID of the AVD host pool"
  value       = azurerm_virtual_desktop_host_pool.main.id
}

output "host_pool_name" {
  description = "Name of the AVD host pool"
  value       = azurerm_virtual_desktop_host_pool.main.name
}

output "workspace_id" {
  description = "ID of the AVD workspace"
  value       = azurerm_virtual_desktop_workspace.main.id
}

output "workspace_name" {
  description = "Name of the AVD workspace"
  value       = azurerm_virtual_desktop_workspace.main.name
}

output "desktop_app_group_id" {
  description = "ID of the desktop application group"
  value       = var.app_groups.desktop_enabled ? azurerm_virtual_desktop_application_group.desktop[0].id : null
}

output "desktop_app_group_name" {
  description = "Name of the desktop application group"
  value       = var.app_groups.desktop_enabled ? azurerm_virtual_desktop_application_group.desktop[0].name : null
}

output "remoteapp_app_group_id" {
  description = "ID of the RemoteApp application group"
  value       = var.app_groups.remoteapp_enabled ? azurerm_virtual_desktop_application_group.remoteapp[0].id : null
}

output "remoteapp_app_group_name" {
  description = "Name of the RemoteApp application group"
  value       = var.app_groups.remoteapp_enabled ? azurerm_virtual_desktop_application_group.remoteapp[0].name : null
}

output "session_host_names" {
  description = "Names of session host VMs"
  value       = azurerm_windows_virtual_machine.session_host[*].name
}

output "session_host_vm_ids" {
  description = "IDs of session host VMs"
  value       = azurerm_windows_virtual_machine.session_host[*].id
}

output "registration_token_secret_name" {
  description = "Name of the registration token secret in Key Vault"
  value       = azurerm_key_vault_secret.registration_token.name
}
