#------------------------------------------------------------------------------
# AWS CloudWatch Module Variables
#------------------------------------------------------------------------------

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}

variable "kms_key_arn" {
  description = "KMS key ARN for encryption"
  type        = string
  default     = ""
}

#------------------------------------------------------------------------------
# SNS Configuration
#------------------------------------------------------------------------------
variable "create_sns_topic" {
  description = "Create SNS topic for alerts"
  type        = bool
  default     = true
}

#------------------------------------------------------------------------------
# Log Group Configuration
#------------------------------------------------------------------------------
variable "create_log_group" {
  description = "Create CloudWatch log group"
  type        = bool
  default     = true
}

variable "log_group_name" {
  description = "Custom log group name (defaults to /{name_prefix}/logs)"
  type        = string
  default     = ""
}

variable "log_retention_days" {
  description = "Log retention in days"
  type        = number
  default     = 30
}

#------------------------------------------------------------------------------
# Dashboard Configuration
#------------------------------------------------------------------------------
variable "create_dashboard" {
  description = "Create CloudWatch dashboard"
  type        = bool
  default     = false
}

variable "dashboard_body" {
  description = "Dashboard body JSON"
  type        = string
  default     = "{}"
}

#------------------------------------------------------------------------------
# Alarm Configuration
#------------------------------------------------------------------------------
variable "alarms" {
  description = "Map of CloudWatch alarms to create"
  type = map(object({
    comparison_operator = string
    evaluation_periods  = number
    metric_name         = string
    namespace           = string
    period              = number
    statistic           = string
    threshold           = number
    description         = string
    dimensions          = map(string)
    treat_missing_data  = optional(string, "missing")
  }))
  default = {}
}

variable "alarm_actions" {
  description = "List of ARNs for alarm actions (used if create_sns_topic is false)"
  type        = list(string)
  default     = []
}

variable "ok_actions" {
  description = "List of ARNs for OK actions"
  type        = list(string)
  default     = []
}

variable "insufficient_data_actions" {
  description = "List of ARNs for insufficient data actions"
  type        = list(string)
  default     = []
}
