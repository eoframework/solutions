#------------------------------------------------------------------------------
# Azure Virtual Desktop Host Pool Module
#------------------------------------------------------------------------------

resource "azurerm_virtual_desktop_host_pool" "this" {
  name                             = var.name
  location                         = var.location
  resource_group_name              = var.resource_group_name
  type                             = var.host_pool_type
  load_balancer_type               = var.load_balancer_type
  maximum_sessions_allowed         = var.maximum_sessions_allowed
  start_vm_on_connect              = var.start_vm_on_connect
  personal_desktop_assignment_type = var.host_pool_type == "Personal" ? var.personal_desktop_assignment_type : null
  validate_environment             = var.validate_environment
  friendly_name                    = var.friendly_name
  description                      = var.description

  tags = var.common_tags
}

#------------------------------------------------------------------------------
# Host Pool Registration Token
#------------------------------------------------------------------------------
resource "time_rotating" "registration_token" {
  rotation_days = var.registration_token_rotation_days
}

resource "azurerm_virtual_desktop_host_pool_registration_info" "this" {
  hostpool_id     = azurerm_virtual_desktop_host_pool.this.id
  expiration_date = time_rotating.registration_token.rotation_rfc3339

  lifecycle {
    replace_triggered_by = [time_rotating.registration_token]
  }
}
