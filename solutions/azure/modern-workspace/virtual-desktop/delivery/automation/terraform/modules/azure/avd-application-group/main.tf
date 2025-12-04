#------------------------------------------------------------------------------
# Azure Virtual Desktop Application Group Module
#------------------------------------------------------------------------------

resource "azurerm_virtual_desktop_application_group" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  type                = var.type
  host_pool_id        = var.host_pool_id
  friendly_name       = var.friendly_name
  description         = var.description

  tags = var.common_tags
}

#------------------------------------------------------------------------------
# Workspace Association
#------------------------------------------------------------------------------
resource "azurerm_virtual_desktop_workspace_application_group_association" "this" {
  count = var.workspace_id != null ? 1 : 0

  workspace_id         = var.workspace_id
  application_group_id = azurerm_virtual_desktop_application_group.this.id
}
