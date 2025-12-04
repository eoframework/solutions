#------------------------------------------------------------------------------
# Monitoring Module
# Creates: Log Analytics Workspace, Application Insights, Action Group, Alerts
# Uses: modules/azure/monitor
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Monitoring (via Azure module)
#------------------------------------------------------------------------------
module "monitor" {
  source = "../../azure/monitor"

  name                = "${var.name_prefix}-law"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = var.monitoring.log_retention_days

  # Application Insights
  application_insights = {
    "${var.name_prefix}-appi" = {
      application_type  = "web"
      retention_in_days = var.monitoring.log_retention_days
    }
  }

  # Action Groups
  action_groups = {
    "${var.name_prefix}-alerts" = {
      short_name = "devops"
      email_receivers = [
        {
          name                    = "operations"
          email_address           = var.monitoring.alert_email
          use_common_alert_schema = true
        }
      ]
    }
  }

  # Metric Alerts
  metric_alerts = var.monitoring.enable_alerts ? {
    "${var.name_prefix}-health-check" = {
      scopes      = [var.app_service_id]
      description = "Health check failed"
      severity    = 1
      criteria = [
        {
          metric_namespace = "Microsoft.Web/sites"
          metric_name      = "HealthCheckStatus"
          aggregation      = "Average"
          operator         = "LessThan"
          threshold        = 100
        }
      ]
      action_group_ids = []  # Will be populated after action group is created
    }
  } : {}

  # Diagnostic Settings
  diagnostic_settings = {
    "${var.name_prefix}-app-diag" = {
      target_resource_id = var.app_service_id
      log_categories     = ["AppServiceHTTPLogs", "AppServiceConsoleLogs", "AppServiceAppLogs"]
      metric_categories  = ["AllMetrics"]
    }
  }

  common_tags = var.common_tags
}

#------------------------------------------------------------------------------
# Update Metric Alert with Action Group (workaround for circular dependency)
#------------------------------------------------------------------------------
resource "azurerm_monitor_metric_alert" "health_check" {
  count = var.monitoring.enable_alerts ? 1 : 0

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
    action_group_id = module.monitor.action_group_ids["${var.name_prefix}-alerts"]
  }

  tags = var.common_tags

  depends_on = [module.monitor]
}
