output "resource_group_name" {
  description = "Name of the created resource group"
  value       = azurerm_resource_group.avd.name
}

output "resource_group_id" {
  description = "ID of the created resource group"
  value       = azurerm_resource_group.avd.id
}

output "virtual_network_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.avd.id
}

output "subnet_id" {
  description = "ID of the AVD subnet"
  value       = azurerm_subnet.avd_hosts.id
}

output "storage_account_name" {
  description = "Name of the storage account for profiles"
  value       = azurerm_storage_account.profiles.name
}

output "storage_account_primary_connection_string" {
  description = "Primary connection string for the storage account"
  value       = azurerm_storage_account.profiles.primary_connection_string
  sensitive   = true
}

output "file_share_url" {
  description = "URL of the FSLogix profiles file share"
  value       = "\\\\${azurerm_storage_account.profiles.name}.file.core.windows.net\\${azurerm_storage_share.profiles.name}"
}

output "host_pool_id" {
  description = "ID of the AVD host pool"
  value       = azurerm_virtual_desktop_host_pool.main.id
}

output "host_pool_name" {
  description = "Name of the AVD host pool"
  value       = azurerm_virtual_desktop_host_pool.main.name
}

output "host_pool_token" {
  description = "Registration token for the host pool"
  value       = azurerm_virtual_desktop_host_pool.main.registration_info[0].token
  sensitive   = true
}

output "workspace_id" {
  description = "ID of the AVD workspace"
  value       = azurerm_virtual_desktop_workspace.main.id
}

output "workspace_name" {
  description = "Name of the AVD workspace"
  value       = azurerm_virtual_desktop_workspace.main.name
}

output "application_group_id" {
  description = "ID of the desktop application group"
  value       = azurerm_virtual_desktop_application_group.desktop.id
}

output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.avd.id
}

output "log_analytics_workspace_key" {
  description = "Primary key of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.avd.primary_shared_key
  sensitive   = true
}

output "session_host_names" {
  description = "Names of the session host VMs"
  value       = azurerm_windows_virtual_machine.session_hosts[*].name
}

output "session_host_ids" {
  description = "IDs of the session host VMs"
  value       = azurerm_windows_virtual_machine.session_hosts[*].id
}

output "session_host_private_ips" {
  description = "Private IP addresses of session hosts"
  value       = azurerm_network_interface.session_hosts[*].private_ip_address
}

output "network_security_group_id" {
  description = "ID of the network security group"
  value       = azurerm_network_security_group.avd.id
}

output "avd_web_client_url" {
  description = "URL for AVD web client access"
  value       = "https://rdweb.wvd.microsoft.com/arm/webclient"
}

output "deployment_summary" {
  description = "Summary of deployed resources"
  value = {
    resource_group    = azurerm_resource_group.avd.name
    location         = azurerm_resource_group.avd.location
    host_pool        = azurerm_virtual_desktop_host_pool.main.name
    workspace        = azurerm_virtual_desktop_workspace.main.name
    session_hosts    = length(azurerm_windows_virtual_machine.session_hosts)
    storage_account  = azurerm_storage_account.profiles.name
    virtual_network  = azurerm_virtual_network.avd.name
  }
}