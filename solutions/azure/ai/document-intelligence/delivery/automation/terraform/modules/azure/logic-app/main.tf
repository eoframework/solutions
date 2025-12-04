#------------------------------------------------------------------------------
# Azure Logic App Module
#------------------------------------------------------------------------------
# Creates Logic App Workflow for orchestration with:
# - Standard or Consumption tier
# - Integration account binding
# - Managed identity
# - Access control policies
#------------------------------------------------------------------------------

resource "azurerm_logic_app_workflow" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  # Identity
  dynamic "identity" {
    for_each = var.identity_type != null ? [1] : []
    content {
      type         = var.identity_type
      identity_ids = var.identity_ids
    }
  }

  # Integration account
  integration_service_environment_id = var.integration_service_environment_id
  logic_app_integration_account_id   = var.logic_app_integration_account_id

  # State and access
  enabled                        = var.enabled
  workflow_schema                = var.workflow_schema
  workflow_version               = var.workflow_version

  # Access control
  dynamic "access_control" {
    for_each = var.access_control != null ? [var.access_control] : []
    content {
      dynamic "action" {
        for_each = lookup(access_control.value, "action", null) != null ? [access_control.value.action] : []
        content {
          allowed_caller_ip_address_range = action.value.allowed_caller_ip_address_range
        }
      }

      dynamic "content" {
        for_each = lookup(access_control.value, "content", null) != null ? [access_control.value.content] : []
        content {
          allowed_caller_ip_address_range = content.value.allowed_caller_ip_address_range
        }
      }

      dynamic "trigger" {
        for_each = lookup(access_control.value, "trigger", null) != null ? [access_control.value.trigger] : []
        content {
          allowed_caller_ip_address_range = trigger.value.allowed_caller_ip_address_range

          dynamic "open_authentication_policy" {
            for_each = lookup(trigger.value, "open_authentication_policies", [])
            content {
              name = open_authentication_policy.value.name

              dynamic "claim" {
                for_each = open_authentication_policy.value.claims
                content {
                  name  = claim.value.name
                  value = claim.value.value
                }
              }
            }
          }
        }
      }

      dynamic "workflow_management" {
        for_each = lookup(access_control.value, "workflow_management", null) != null ? [access_control.value.workflow_management] : []
        content {
          allowed_caller_ip_address_range = workflow_management.value.allowed_caller_ip_address_range
        }
      }
    }
  }

  # Workflow parameters
  workflow_parameters = var.workflow_parameters

  # Parameters (runtime)
  parameters = var.parameters

  tags = var.common_tags

  lifecycle {
    ignore_changes = [
      parameters,
      workflow_parameters,
    ]
  }
}
