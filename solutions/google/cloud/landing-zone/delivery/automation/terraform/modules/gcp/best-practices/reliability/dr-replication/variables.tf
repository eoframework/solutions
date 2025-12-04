#------------------------------------------------------------------------------
# GCP DR Replication Module - Variables
#------------------------------------------------------------------------------

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "dr_region" {
  description = "DR region for cross-region resources"
  type        = string
}

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

variable "common_labels" {
  description = "Common labels for all resources"
  type        = map(string)
  default     = {}
}
