#------------------------------------------------------------------------------
# Azure Monitor Module - Variables
#------------------------------------------------------------------------------

variable "name" {
  description = "Log Analytics Workspace name"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "sku" {
  description = "Log Analytics Workspace SKU"
  type        = string
  default     = "PerGB2018"
}

variable "retention_in_days" {
  description = "Retention in days"
  type        = number
  default     = 30
}

variable "daily_quota_gb" {
  description = "Daily quota in GB"
  type        = number
  default     = null
}

#------------------------------------------------------------------------------
# Application Insights
#------------------------------------------------------------------------------
variable "application_insights" {
  description = "Application Insights instances"
  type = map(object({
    application_type     = string
    retention_in_days    = optional(number, 90)
    daily_data_cap_in_gb = optional(number)
    sampling_percentage  = optional(number)
    disable_ip_masking   = optional(bool, false)
  }))
  default = {}
}

#------------------------------------------------------------------------------
# Action Groups
#------------------------------------------------------------------------------
variable "action_groups" {
  description = "Action groups"
  type = map(object({
    short_name = string
    enabled    = optional(bool, true)
    email_receivers = optional(list(object({
      name                    = string
      email_address           = string
      use_common_alert_schema = optional(bool, true)
    })), [])
    sms_receivers = optional(list(object({
      name         = string
      country_code = string
      phone_number = string
    })), [])
    webhook_receivers = optional(list(object({
      name                    = string
      service_uri             = string
      use_common_alert_schema = optional(bool, true)
    })), [])
    azure_function_receivers = optional(list(object({
      name                     = string
      function_app_resource_id = string
      function_name            = string
      http_trigger_url         = string
      use_common_alert_schema  = optional(bool, true)
    })), [])
    logic_app_receivers = optional(list(object({
      name                    = string
      resource_id             = string
      callback_url            = string
      use_common_alert_schema = optional(bool, true)
    })), [])
  }))
  default = {}
}

#------------------------------------------------------------------------------
# Metric Alerts
#------------------------------------------------------------------------------
variable "metric_alerts" {
  description = "Metric alerts"
  type = map(object({
    scopes               = list(string)
    description          = optional(string)
    severity             = optional(number, 3)
    enabled              = optional(bool, true)
    auto_mitigate        = optional(bool, true)
    frequency            = optional(string, "PT1M")
    window_size          = optional(string, "PT5M")
    target_resource_type = optional(string)
    criteria = optional(list(object({
      metric_namespace = string
      metric_name      = string
      aggregation      = string
      operator         = string
      threshold        = number
      dimensions = optional(list(object({
        name     = string
        operator = string
        values   = list(string)
      })), [])
    })), [])
    dynamic_criteria = optional(list(object({
      metric_namespace  = string
      metric_name       = string
      aggregation       = string
      operator          = string
      alert_sensitivity = string
      dimensions = optional(list(object({
        name     = string
        operator = string
        values   = list(string)
      })), [])
    })), [])
    action_group_ids = optional(list(string), [])
  }))
  default = {}
}

#------------------------------------------------------------------------------
# Log Alerts
#------------------------------------------------------------------------------
variable "log_alerts" {
  description = "Log alerts"
  type = map(object({
    scopes                  = list(string)
    evaluation_frequency    = optional(string, "PT5M")
    window_duration         = optional(string, "PT5M")
    severity                = optional(number, 3)
    enabled                 = optional(bool, true)
    description             = optional(string)
    auto_mitigation_enabled = optional(bool, true)
    query                   = string
    time_aggregation_method = string
    threshold               = number
    operator                = string
    dimensions = optional(list(object({
      name     = string
      operator = string
      values   = list(string)
    })), [])
    failing_periods = optional(object({
      minimum_failing_periods_to_trigger_alert = number
      number_of_evaluation_periods             = number
    }))
    action_group_ids = optional(list(string), [])
  }))
  default = {}
}

#------------------------------------------------------------------------------
# Diagnostic Settings
#------------------------------------------------------------------------------
variable "diagnostic_settings" {
  description = "Diagnostic settings"
  type = map(object({
    target_resource_id             = string
    storage_account_id             = optional(string)
    eventhub_name                  = optional(string)
    eventhub_authorization_rule_id = optional(string)
    log_categories                 = optional(list(string), [])
    metric_categories              = optional(list(string), ["AllMetrics"])
  }))
  default = {}
}

#------------------------------------------------------------------------------
# Tags
#------------------------------------------------------------------------------
variable "common_tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
