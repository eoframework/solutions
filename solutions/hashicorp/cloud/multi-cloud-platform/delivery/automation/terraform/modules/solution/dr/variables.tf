#------------------------------------------------------------------------------
# DR Module Variables
#------------------------------------------------------------------------------

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
}

variable "kms_key_arn" {
  description = "Primary region KMS key ARN"
  type        = string
}

variable "dr_region" {
  description = "DR region"
  type        = string
}

variable "dr" {
  description = "DR configuration"
  type = object({
    enabled                   = bool
    key_rotation_days         = number
    enable_lifecycle          = bool
    archive_after_days        = number
    coldline_after_days       = number
    enable_health_check       = bool
    primary_endpoint          = string
    health_check_port         = number
    health_check_path         = string
    health_check_interval_sec = number
    health_check_timeout_sec  = number
    healthy_threshold         = number
    unhealthy_threshold       = number
  })
}
