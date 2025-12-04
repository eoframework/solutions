#------------------------------------------------------------------------------
# Azure Virtual Desktop Application Group Module - Outputs
#------------------------------------------------------------------------------

output "id" {
  description = "Application group ID"
  value       = azurerm_virtual_desktop_application_group.this.id
}

output "name" {
  description = "Application group name"
  value       = azurerm_virtual_desktop_application_group.this.name
}
