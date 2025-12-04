#------------------------------------------------------------------------------
# Azure Monitor Module
#------------------------------------------------------------------------------
# Creates monitoring resources:
# - Log Analytics Workspace
# - Application Insights
# - Diagnostic Settings
# - Action Groups for alerts
#------------------------------------------------------------------------------

resource "azurerm_log_analytics_workspace" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku
  retention_in_days   = var.retention_in_days

  tags = var.common_tags
}

#------------------------------------------------------------------------------
# Application Insights
#------------------------------------------------------------------------------
resource "azurerm_application_insights" "this" {
  count = var.create_application_insights ? 1 : 0

  name                = "${var.name}-appinsights"
  location            = var.location
  resource_group_name = var.resource_group_name
  workspace_id        = azurerm_log_analytics_workspace.this.id
  application_type    = var.application_type

  tags = var.common_tags
}

#------------------------------------------------------------------------------
# Diagnostic Settings
#------------------------------------------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "this" {
  for_each = var.diagnostic_settings

  name                       = each.key
  target_resource_id         = each.value.target_resource_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id

  dynamic "enabled_log" {
    for_each = lookup(each.value, "log_categories", [])
    content {
      category = enabled_log.value
    }
  }

  dynamic "metric" {
    for_each = lookup(each.value, "metric_categories", [])
    content {
      category = metric.value
      enabled  = true
    }
  }
}

#------------------------------------------------------------------------------
# Action Group
#------------------------------------------------------------------------------
resource "azurerm_monitor_action_group" "this" {
  for_each = var.action_groups

  name                = each.key
  resource_group_name = var.resource_group_name
  short_name          = each.value.short_name

  dynamic "email_receiver" {
    for_each = lookup(each.value, "email_receivers", [])
    content {
      name          = email_receiver.value.name
      email_address = email_receiver.value.email_address
    }
  }

  dynamic "webhook_receiver" {
    for_each = lookup(each.value, "webhook_receivers", [])
    content {
      name        = webhook_receiver.value.name
      service_uri = webhook_receiver.value.service_uri
    }
  }

  tags = var.common_tags
}
