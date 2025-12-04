#------------------------------------------------------------------------------
# Monitoring Module
# Creates: Log Analytics, Application Insights, Alerts, Action Groups
# Uses: modules/azure/monitor
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Log Analytics Workspace & Application Insights (via Azure module)
#------------------------------------------------------------------------------
module "monitor" {
  source = "../../azure/monitor"

  name                        = "${var.name_prefix}-law"
  resource_group_name         = var.resource_group_name
  location                    = var.location
  sku                         = "PerGB2018"
  retention_in_days           = var.monitoring.log_retention_days
  create_application_insights = true
  application_type            = "other"

  # Diagnostic settings for AVD resources
  diagnostic_settings = {
    hostpool = {
      target_resource_id = var.host_pool_id
      log_categories     = ["Checkpoint", "Error", "Management", "Connection", "HostRegistration"]
      metric_categories  = ["AllMetrics"]
    }
    workspace = {
      target_resource_id = var.workspace_id
      log_categories     = ["Checkpoint", "Error", "Management", "Feed"]
      metric_categories  = ["AllMetrics"]
    }
  }

  # Action groups for alerts
  action_groups = var.monitoring.enable_alerts ? {
    main = {
      short_name = "avdalerts"
      email_receivers = [
        {
          name          = "sendtoadmin"
          email_address = var.monitoring.alert_email
        }
      ]
    }
  } : {}

  common_tags = var.common_tags
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
