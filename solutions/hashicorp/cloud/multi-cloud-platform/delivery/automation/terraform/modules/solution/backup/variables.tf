#------------------------------------------------------------------------------
# Backup Module Variables
#------------------------------------------------------------------------------

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
}

variable "kms_key_arn" {
  description = "KMS key ARN for backup encryption"
  type        = string
}

variable "backup" {
  description = "Backup configuration"
  type = object({
    enabled                     = bool
    daily_schedule              = string
    retention_days              = number
    enable_weekly               = bool
    weekly_schedule             = string
    weekly_retention_days       = number
    enable_cross_region         = bool
    cross_region_retention_days = number
    dr_kms_key_arn              = string
  })
}
