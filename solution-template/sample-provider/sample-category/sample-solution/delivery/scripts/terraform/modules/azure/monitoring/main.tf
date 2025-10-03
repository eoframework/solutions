# Azure Monitoring Module
# Azure Monitor, Log Analytics, and Application Insights configuration

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# Local values for Azure monitoring
locals {
  monitoring_name_prefix = "${var.name_prefix}-monitoring"

  # Common tags for monitoring resources
  monitoring_tags = merge(var.tags, {
    Module  = "azure-monitoring"
    Purpose = "observability"
  })
}

# Resource Group for monitoring resources
resource "azurerm_resource_group" "monitoring" {
  name     = "${local.monitoring_name_prefix}-rg"
  location = var.location

  tags = local.monitoring_tags
}

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "main" {
  name                = "${local.monitoring_name_prefix}-workspace"
  location            = azurerm_resource_group.monitoring.location
  resource_group_name = azurerm_resource_group.monitoring.name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_retention_days

  tags = local.monitoring_tags
}

# Application Insights
resource "azurerm_application_insights" "main" {
  name                = "${local.monitoring_name_prefix}-insights"
  location            = azurerm_resource_group.monitoring.location
  resource_group_name = azurerm_resource_group.monitoring.name
  workspace_id        = azurerm_log_analytics_workspace.main.id
  application_type    = "web"

  tags = local.monitoring_tags
}

# Action Group for alerts
resource "azurerm_monitor_action_group" "main" {
  name                = "${local.monitoring_name_prefix}-actions"
  resource_group_name = azurerm_resource_group.monitoring.name
  short_name          = "monitoring"

  dynamic "email_receiver" {
    for_each = var.notification_emails
    content {
      name          = "email-${email_receiver.key}"
      email_address = email_receiver.value
    }
  }

  tags = local.monitoring_tags
}

# Metric Alerts
resource "azurerm_monitor_metric_alert" "cpu_high" {
  name                = "${local.monitoring_name_prefix}-cpu-high"
  resource_group_name = azurerm_resource_group.monitoring.name
  scopes              = [azurerm_resource_group.monitoring.id]
  description         = "Alert when CPU usage is high"
  severity            = 2

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }

  tags = local.monitoring_tags
}

resource "azurerm_monitor_metric_alert" "memory_high" {
  name                = "${local.monitoring_name_prefix}-memory-high"
  resource_group_name = azurerm_resource_group.monitoring.name
  scopes              = [azurerm_resource_group.monitoring.id]
  description         = "Alert when memory usage is high"
  severity            = 2

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Available Memory Bytes"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 1000000000 # 1GB in bytes
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }

  tags = local.monitoring_tags
}

# Activity Log Alert for resource creation/deletion
resource "azurerm_monitor_activity_log_alert" "resource_health" {
  name                = "${local.monitoring_name_prefix}-resource-health"
  resource_group_name = azurerm_resource_group.monitoring.name
  scopes              = [azurerm_resource_group.monitoring.id]
  description         = "Alert on resource health events"

  criteria {
    category = "ResourceHealth"
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }

  tags = local.monitoring_tags
}

# Diagnostic Settings for Activity Logs
resource "azurerm_monitor_diagnostic_setting" "subscription" {
  name                       = "${local.monitoring_name_prefix}-diag"
  target_resource_id         = "/subscriptions/${var.subscription_id}"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  enabled_log {
    category = "Administrative"
  }

  enabled_log {
    category = "Security"
  }

  enabled_log {
    category = "Alert"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}