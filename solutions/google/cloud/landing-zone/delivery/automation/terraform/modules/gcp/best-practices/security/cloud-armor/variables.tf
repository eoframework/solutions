#------------------------------------------------------------------------------
# GCP Cloud Armor Module - Variables
#------------------------------------------------------------------------------

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "cloud_armor" {
  description = "Cloud Armor configuration"
  type = object({
    enabled                        = bool
    enable_owasp_rules             = bool
    enable_rate_limiting           = bool
    rate_limit_requests_per_minute = number
    rate_limit_ban_duration_sec    = number
    blocked_countries              = list(string)
  })
  default = {
    enabled                        = true
    enable_owasp_rules             = true
    enable_rate_limiting           = true
    rate_limit_requests_per_minute = 1000
    rate_limit_ban_duration_sec    = 600
    blocked_countries              = []
  }
}
