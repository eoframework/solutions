#------------------------------------------------------------------------------
# Azure Monitor Module
#------------------------------------------------------------------------------
# Creates:
# - Log Analytics Workspace
# - Application Insights
# - Action Groups
# - Metric Alerts
# - Log Alerts
# - Diagnostic Settings
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Log Analytics Workspace
#------------------------------------------------------------------------------
resource "azurerm_log_analytics_workspace" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku
  retention_in_days   = var.retention_in_days
  daily_quota_gb      = var.daily_quota_gb

  tags = var.common_tags
}

#------------------------------------------------------------------------------
# Application Insights
#------------------------------------------------------------------------------
resource "azurerm_application_insights" "this" {
  for_each = var.application_insights

  name                = each.key
  location            = var.location
  resource_group_name = var.resource_group_name
  workspace_id        = azurerm_log_analytics_workspace.this.id
  application_type    = each.value.application_type
  retention_in_days   = lookup(each.value, "retention_in_days", 90)
  daily_data_cap_in_gb = lookup(each.value, "daily_data_cap_in_gb", null)
  sampling_percentage = lookup(each.value, "sampling_percentage", null)
  disable_ip_masking  = lookup(each.value, "disable_ip_masking", false)

  tags = var.common_tags
}

#------------------------------------------------------------------------------
# Action Groups
#------------------------------------------------------------------------------
resource "azurerm_monitor_action_group" "this" {
  for_each = var.action_groups

  name                = each.key
  resource_group_name = var.resource_group_name
  short_name          = each.value.short_name
  enabled             = lookup(each.value, "enabled", true)

  dynamic "email_receiver" {
    for_each = lookup(each.value, "email_receivers", [])
    content {
      name                    = email_receiver.value.name
      email_address           = email_receiver.value.email_address
      use_common_alert_schema = lookup(email_receiver.value, "use_common_alert_schema", true)
    }
  }

  dynamic "sms_receiver" {
    for_each = lookup(each.value, "sms_receivers", [])
    content {
      name         = sms_receiver.value.name
      country_code = sms_receiver.value.country_code
      phone_number = sms_receiver.value.phone_number
    }
  }

  dynamic "webhook_receiver" {
    for_each = lookup(each.value, "webhook_receivers", [])
    content {
      name                    = webhook_receiver.value.name
      service_uri             = webhook_receiver.value.service_uri
      use_common_alert_schema = lookup(webhook_receiver.value, "use_common_alert_schema", true)
    }
  }

  dynamic "azure_function_receiver" {
    for_each = lookup(each.value, "azure_function_receivers", [])
    content {
      name                     = azure_function_receiver.value.name
      function_app_resource_id = azure_function_receiver.value.function_app_resource_id
      function_name            = azure_function_receiver.value.function_name
      http_trigger_url         = azure_function_receiver.value.http_trigger_url
      use_common_alert_schema  = lookup(azure_function_receiver.value, "use_common_alert_schema", true)
    }
  }

  dynamic "logic_app_receiver" {
    for_each = lookup(each.value, "logic_app_receivers", [])
    content {
      name                    = logic_app_receiver.value.name
      resource_id             = logic_app_receiver.value.resource_id
      callback_url            = logic_app_receiver.value.callback_url
      use_common_alert_schema = lookup(logic_app_receiver.value, "use_common_alert_schema", true)
    }
  }

  tags = var.common_tags
}

#------------------------------------------------------------------------------
# Metric Alerts
#------------------------------------------------------------------------------
resource "azurerm_monitor_metric_alert" "this" {
  for_each = var.metric_alerts

  name                = each.key
  resource_group_name = var.resource_group_name
  scopes              = each.value.scopes
  description         = lookup(each.value, "description", null)
  severity            = lookup(each.value, "severity", 3)
  enabled             = lookup(each.value, "enabled", true)
  auto_mitigate       = lookup(each.value, "auto_mitigate", true)
  frequency           = lookup(each.value, "frequency", "PT1M")
  window_size         = lookup(each.value, "window_size", "PT5M")
  target_resource_type = lookup(each.value, "target_resource_type", null)

  dynamic "criteria" {
    for_each = lookup(each.value, "criteria", [])
    content {
      metric_namespace = criteria.value.metric_namespace
      metric_name      = criteria.value.metric_name
      aggregation      = criteria.value.aggregation
      operator         = criteria.value.operator
      threshold        = criteria.value.threshold

      dynamic "dimension" {
        for_each = lookup(criteria.value, "dimensions", [])
        content {
          name     = dimension.value.name
          operator = dimension.value.operator
          values   = dimension.value.values
        }
      }
    }
  }

  dynamic "dynamic_criteria" {
    for_each = lookup(each.value, "dynamic_criteria", [])
    content {
      metric_namespace  = dynamic_criteria.value.metric_namespace
      metric_name       = dynamic_criteria.value.metric_name
      aggregation       = dynamic_criteria.value.aggregation
      operator          = dynamic_criteria.value.operator
      alert_sensitivity = dynamic_criteria.value.alert_sensitivity

      dynamic "dimension" {
        for_each = lookup(dynamic_criteria.value, "dimensions", [])
        content {
          name     = dimension.value.name
          operator = dimension.value.operator
          values   = dimension.value.values
        }
      }
    }
  }

  dynamic "action" {
    for_each = lookup(each.value, "action_group_ids", [])
    content {
      action_group_id = action.value
    }
  }

  tags = var.common_tags
}

#------------------------------------------------------------------------------
# Scheduled Query Rules (Log Alerts)
#------------------------------------------------------------------------------
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "this" {
  for_each = var.log_alerts

  name                = each.key
  resource_group_name = var.resource_group_name
  location            = var.location

  evaluation_frequency = lookup(each.value, "evaluation_frequency", "PT5M")
  window_duration      = lookup(each.value, "window_duration", "PT5M")
  scopes               = each.value.scopes
  severity             = lookup(each.value, "severity", 3)
  enabled              = lookup(each.value, "enabled", true)
  description          = lookup(each.value, "description", null)
  auto_mitigation_enabled = lookup(each.value, "auto_mitigation_enabled", true)

  criteria {
    query                   = each.value.query
    time_aggregation_method = each.value.time_aggregation_method
    threshold               = each.value.threshold
    operator                = each.value.operator

    dynamic "dimension" {
      for_each = lookup(each.value, "dimensions", [])
      content {
        name     = dimension.value.name
        operator = dimension.value.operator
        values   = dimension.value.values
      }
    }

    dynamic "failing_periods" {
      for_each = lookup(each.value, "failing_periods", null) != null ? [each.value.failing_periods] : []
      content {
        minimum_failing_periods_to_trigger_alert = failing_periods.value.minimum_failing_periods_to_trigger_alert
        number_of_evaluation_periods             = failing_periods.value.number_of_evaluation_periods
      }
    }
  }

  dynamic "action" {
    for_each = lookup(each.value, "action_group_ids", [])
    content {
      action_groups = [action.value]
    }
  }

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
  storage_account_id         = lookup(each.value, "storage_account_id", null)
  eventhub_name              = lookup(each.value, "eventhub_name", null)
  eventhub_authorization_rule_id = lookup(each.value, "eventhub_authorization_rule_id", null)

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
