#------------------------------------------------------------------------------
# Best Practices Module - Variables
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Common Variables
#------------------------------------------------------------------------------
variable "org_id" {
  description = "GCP Organization ID"
  type        = string
}

variable "billing_account_id" {
  description = "Billing account ID"
  type        = string
}

variable "security_project_id" {
  description = "Security project ID"
  type        = string
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "project_ids" {
  description = "List of project IDs to monitor (format: projects/PROJECT_ID)"
  type        = list(string)
}

variable "dr_region" {
  description = "DR region for cross-region resources"
  type        = string
}

variable "notification_channels" {
  description = "Monitoring notification channel IDs"
  type        = list(string)
  default     = []
}

variable "scc_pubsub_topic_id" {
  description = "Pub/Sub topic ID for SCC notifications"
  type        = string
  default     = ""
}

variable "common_labels" {
  description = "Common labels for all resources"
  type        = map(string)
  default     = {}
}

#------------------------------------------------------------------------------
# Budget Configuration
#------------------------------------------------------------------------------
variable "budget" {
  description = "Budget configuration"
  type = object({
    enabled                = bool
    monthly_amount         = number
    currency               = string
    alert_thresholds       = list(number)
    enable_forecast_alerts = bool
    forecast_threshold     = number
  })
  default = {
    enabled                = true
    monthly_amount         = 1000
    currency               = "USD"
    alert_thresholds       = [50, 80, 100]
    enable_forecast_alerts = true
    forecast_threshold     = 100
  }
}

#------------------------------------------------------------------------------
# Security Configuration
#------------------------------------------------------------------------------
variable "security" {
  description = "Security configuration"
  type = object({
    scc_tier                       = string
    scc_public_resource_detection  = bool
    scc_notifications_enabled      = bool
    cloud_armor_enabled            = bool
    cloud_armor_owasp_rules        = bool
    cloud_armor_rate_limiting      = bool
    rate_limit_requests_per_minute = number
    rate_limit_ban_duration_sec    = number
    blocked_countries              = list(string)
  })
  default = {
    scc_tier                       = "Standard"
    scc_public_resource_detection  = true
    scc_notifications_enabled      = false
    cloud_armor_enabled            = true
    cloud_armor_owasp_rules        = true
    cloud_armor_rate_limiting      = true
    rate_limit_requests_per_minute = 1000
    rate_limit_ban_duration_sec    = 600
    blocked_countries              = []
  }
}

#------------------------------------------------------------------------------
# DR Configuration
#------------------------------------------------------------------------------
variable "dr" {
  description = "DR configuration"
  type = object({
    enabled                   = bool
    cross_region_replication  = bool
    archive_after_days        = number
    coldline_after_days       = number
    enable_health_check       = bool
    health_check_interval_sec = number
    health_check_timeout_sec  = number
    healthy_threshold         = number
    unhealthy_threshold       = number
    health_check_port         = number
    health_check_path         = string
    enable_dr_kms             = bool
    key_rotation_days         = number
  })
  default = {
    enabled                   = true
    cross_region_replication  = true
    archive_after_days        = 90
    coldline_after_days       = 365
    enable_health_check       = true
    health_check_interval_sec = 5
    health_check_timeout_sec  = 5
    healthy_threshold         = 2
    unhealthy_threshold       = 3
    health_check_port         = 80
    health_check_path         = "/health"
    enable_dr_kms             = true
    key_rotation_days         = 90
  }
}
