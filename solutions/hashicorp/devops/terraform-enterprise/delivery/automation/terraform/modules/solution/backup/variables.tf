#------------------------------------------------------------------------------
# Backup Module Variables (Solution-Level)
#------------------------------------------------------------------------------

variable "name_prefix" {
  description = "Name prefix for resources"
  type        = string
}

variable "common_tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}

variable "kms_key_arn" {
  description = "KMS key ARN for encryption"
  type        = string
}

variable "rds_arn" {
  description = "RDS ARN to backup"
  type        = string
}

variable "dr_vault_arn" {
  description = "DR backup vault ARN for cross-region copy (created at environment level)"
  type        = string
  default     = ""
}

variable "backup" {
  description = "Backup configuration"
  type = object({
    enabled             = bool
    daily_retention     = number
    weekly_retention    = number
    enable_cross_region = bool
  })
}
