#------------------------------------------------------------------------------
# Azure Virtual Desktop Workspace Module
#------------------------------------------------------------------------------

resource "azurerm_virtual_desktop_workspace" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  friendly_name       = var.friendly_name
  description         = var.description

  tags = var.common_tags
}
