#------------------------------------------------------------------------------
# Monitoring Module
# Creates: Log Analytics, Application Insights, Alerts, Action Groups
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Log Analytics Workspace
#------------------------------------------------------------------------------
resource "azurerm_log_analytics_workspace" "main" {
  name                = "${var.name_prefix}-law"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = var.monitoring.log_retention_days
  tags                = var.common_tags
}

#------------------------------------------------------------------------------
# Application Insights
#------------------------------------------------------------------------------
resource "azurerm_application_insights" "main" {
  name                = "${var.name_prefix}-appinsights"
  location            = var.location
  resource_group_name = var.resource_group_name
  workspace_id        = azurerm_log_analytics_workspace.main.id
  application_type    = "other"
  tags                = var.common_tags
}

#------------------------------------------------------------------------------
# Diagnostic Settings for Host Pool
#------------------------------------------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "host_pool" {
  name                       = "${var.name_prefix}-hostpool-diag"
  target_resource_id         = var.host_pool_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  enabled_log {
    category = "Checkpoint"
  }

  enabled_log {
    category = "Error"
  }

  enabled_log {
    category = "Management"
  }

  enabled_log {
    category = "Connection"
  }

  enabled_log {
    category = "HostRegistration"
  }

  metric {
    category = "AllMetrics"
  }
}

#------------------------------------------------------------------------------
# Diagnostic Settings for Workspace
#------------------------------------------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "workspace" {
  name                       = "${var.name_prefix}-workspace-diag"
  target_resource_id         = var.workspace_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  enabled_log {
    category = "Checkpoint"
  }

  enabled_log {
    category = "Error"
  }

  enabled_log {
    category = "Management"
  }

  enabled_log {
    category = "Feed"
  }

  metric {
    category = "AllMetrics"
  }
}

#------------------------------------------------------------------------------
# Action Group for Alerts
#------------------------------------------------------------------------------
resource "azurerm_monitor_action_group" "main" {
  count               = var.monitoring.enable_alerts ? 1 : 0
  name                = "${var.name_prefix}-action-group"
  resource_group_name = var.resource_group_name
  short_name          = "avdalerts"

  email_receiver {
    name          = "sendtoadmin"
    email_address = var.monitoring.alert_email
  }

  tags = var.common_tags
}

#------------------------------------------------------------------------------
# Azure Monitor Workbook for AVD Insights
#------------------------------------------------------------------------------
resource "azurerm_application_insights_workbook" "avd_insights" {
  count               = var.monitoring.enable_dashboard ? 1 : 0
  name                = "${var.name_prefix}-avd-workbook"
  location            = var.location
  resource_group_name = var.resource_group_name
  display_name        = "AVD Insights Dashboard"
  data_json = jsonencode({
    version = "Notebook/1.0"
    items = [
      {
        type = 1
        content = {
          json = "## Azure Virtual Desktop Insights\n\nMonitoring dashboard for AVD environment"
        }
      }
    ]
  })

  tags = var.common_tags
}
