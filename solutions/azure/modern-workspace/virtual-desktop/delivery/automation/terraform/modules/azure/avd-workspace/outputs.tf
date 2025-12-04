#------------------------------------------------------------------------------
# Azure Virtual Desktop Workspace Module - Outputs
#------------------------------------------------------------------------------

output "id" {
  description = "Workspace ID"
  value       = azurerm_virtual_desktop_workspace.this.id
}

output "name" {
  description = "Workspace name"
  value       = azurerm_virtual_desktop_workspace.this.name
}
