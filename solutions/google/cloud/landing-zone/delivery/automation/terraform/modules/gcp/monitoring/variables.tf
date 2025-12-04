#------------------------------------------------------------------------------
# GCP Cloud Monitoring Module - Variables
#------------------------------------------------------------------------------

variable "project_id" {
  description = "GCP project ID for monitoring resources"
  type        = string
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "monitoring" {
  description = "Monitoring configuration"
  type = object({
    dashboard_count       = number
    alert_policy_count    = number
    notification_channels = list(string)
    uptime_check_enabled  = bool
    log_based_metrics     = bool
  })
}

variable "common_labels" {
  description = "Common labels for all resources"
  type        = map(string)
  default     = {}
}

variable "notification_email" {
  description = "Email address for notifications"
  type        = string
  default     = ""
}
