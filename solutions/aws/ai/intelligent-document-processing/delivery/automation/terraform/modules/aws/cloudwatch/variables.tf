# Generic AWS CloudWatch Module - Variables

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "kms_key_arn" {
  description = "KMS key ARN for encrypting logs and SNS"
  type        = string
  default     = null
}

#------------------------------------------------------------------------------
# Log Groups
#------------------------------------------------------------------------------

variable "log_groups" {
  description = "Map of CloudWatch log groups to create"
  type = map(object({
    name           = string
    retention_days = number
  }))
  default = {}
}

#------------------------------------------------------------------------------
# Metric Filters
#------------------------------------------------------------------------------

variable "metric_filters" {
  description = "Map of CloudWatch metric filters to create"
  type = map(object({
    log_group_name   = string
    pattern          = string
    metric_name      = string
    metric_namespace = string
    metric_value     = string
    default_value    = optional(string)
  }))
  default = {}
}

#------------------------------------------------------------------------------
# Alarms
#------------------------------------------------------------------------------

variable "alarms" {
  description = "Map of CloudWatch alarms to create"
  type = map(object({
    description         = string
    comparison_operator = string
    evaluation_periods  = number
    metric_name         = string
    namespace           = string
    period              = number
    statistic           = string
    threshold           = number
    treat_missing_data  = optional(string)
    dimensions          = optional(map(string))
  }))
  default = {}
}

variable "alarm_actions" {
  description = "List of ARNs to notify when alarm triggers"
  type        = list(string)
  default     = []
}

variable "ok_actions" {
  description = "List of ARNs to notify when alarm returns to OK"
  type        = list(string)
  default     = []
}

variable "insufficient_data_actions" {
  description = "List of ARNs to notify on insufficient data"
  type        = list(string)
  default     = []
}

#------------------------------------------------------------------------------
# Dashboard
#------------------------------------------------------------------------------

variable "create_dashboard" {
  description = "Create a CloudWatch dashboard"
  type        = bool
  default     = false
}

variable "dashboard_body" {
  description = "Custom dashboard body JSON (overrides dashboard_widgets)"
  type        = string
  default     = ""
}

variable "dashboard_widgets" {
  description = "List of dashboard widget configurations"
  type        = list(any)
  default     = []
}

#------------------------------------------------------------------------------
# SNS Topic
#------------------------------------------------------------------------------

variable "create_sns_topic" {
  description = "Create an SNS topic for alarms"
  type        = bool
  default     = false
}

variable "alarm_email_endpoints" {
  description = "Email addresses to subscribe to alarm SNS topic"
  type        = list(string)
  default     = []
}

#------------------------------------------------------------------------------
# Composite Alarms
#------------------------------------------------------------------------------

variable "composite_alarms" {
  description = "Map of composite alarms to create"
  type = map(object({
    description = string
    alarm_rule  = string
  }))
  default = {}
}
