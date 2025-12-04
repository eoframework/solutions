#------------------------------------------------------------------------------
# Monitoring Module
# Creates: Log Analytics Workspace, Application Insights, Action Group
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

  tags = var.common_tags
}

#------------------------------------------------------------------------------
# Application Insights
#------------------------------------------------------------------------------
resource "azurerm_application_insights" "main" {
  name                = "${var.name_prefix}-appi"
  location            = var.location
  resource_group_name = var.resource_group_name
  workspace_id        = azurerm_log_analytics_workspace.main.id
  application_type    = "web"

  tags = var.common_tags
}

#------------------------------------------------------------------------------
# Action Group for Alerts
#------------------------------------------------------------------------------
resource "azurerm_monitor_action_group" "main" {
  name                = "${var.name_prefix}-alerts"
  resource_group_name = var.resource_group_name
  short_name          = "devops"

  email_receiver {
    name                    = "operations"
    email_address           = var.monitoring.alert_email
    use_common_alert_schema = true
  }

  tags = var.common_tags
}

#------------------------------------------------------------------------------
# Diagnostic Settings for App Service
#------------------------------------------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "app_service" {
  name                       = "${var.name_prefix}-app-diag"
  target_resource_id         = var.app_service_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  enabled_log {
    category = "AppServiceHTTPLogs"
  }

  enabled_log {
    category = "AppServiceConsoleLogs"
  }

  enabled_log {
    category = "AppServiceAppLogs"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

#------------------------------------------------------------------------------
# Health Check Alert
#------------------------------------------------------------------------------
resource "azurerm_monitor_metric_alert" "health_check" {
  count               = var.monitoring.enable_alerts ? 1 : 0
  name                = "${var.name_prefix}-health-check"
  resource_group_name = var.resource_group_name
  scopes              = [var.app_service_id]
  description         = "Health check failed"
  severity            = 1

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "HealthCheckStatus"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 100
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }

  tags = var.common_tags
}
