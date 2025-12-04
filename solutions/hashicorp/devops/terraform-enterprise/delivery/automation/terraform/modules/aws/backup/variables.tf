#------------------------------------------------------------------------------
# AWS Backup Module Variables
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
  description = "KMS key ARN for vault encryption"
  type        = string
  default     = ""
}

#------------------------------------------------------------------------------
# Daily Backup Configuration
#------------------------------------------------------------------------------
variable "daily_schedule" {
  description = "Cron expression for daily backup schedule"
  type        = string
  default     = "cron(0 5 ? * * *)"
}

variable "daily_retention_days" {
  description = "Number of days to retain daily backups"
  type        = number
  default     = 7
}

#------------------------------------------------------------------------------
# Weekly Backup Configuration
#------------------------------------------------------------------------------
variable "weekly_schedule" {
  description = "Cron expression for weekly backup schedule"
  type        = string
  default     = "cron(0 5 ? * SUN *)"
}

variable "weekly_retention_days" {
  description = "Number of days to retain weekly backups (0 to disable)"
  type        = number
  default     = 30
}

#------------------------------------------------------------------------------
# Monthly Backup Configuration
#------------------------------------------------------------------------------
variable "monthly_schedule" {
  description = "Cron expression for monthly backup schedule"
  type        = string
  default     = "cron(0 5 1 * ? *)"
}

variable "monthly_retention_days" {
  description = "Number of days to retain monthly backups (0 to disable)"
  type        = number
  default     = 365
}

variable "cold_storage_after_days" {
  description = "Days before moving to cold storage (0 to disable)"
  type        = number
  default     = 90
}

#------------------------------------------------------------------------------
# Cross-Region Copy Configuration
#------------------------------------------------------------------------------
variable "enable_cross_region_copy" {
  description = "Enable cross-region backup copy for DR"
  type        = bool
  default     = false
}

variable "dr_vault_arn" {
  description = "DR backup vault ARN for cross-region copy"
  type        = string
  default     = ""
}

variable "dr_retention_days" {
  description = "Retention days for DR copies"
  type        = number
  default     = 30
}

#------------------------------------------------------------------------------
# Backup Selection
#------------------------------------------------------------------------------
variable "resource_arns" {
  description = "List of resource ARNs to backup"
  type        = list(string)
  default     = []
}

variable "selection_tags" {
  description = "Tags to select resources for backup"
  type = list(object({
    key   = string
    value = string
  }))
  default = []
}

#------------------------------------------------------------------------------
# Additional Permissions
#------------------------------------------------------------------------------
variable "enable_s3_backup" {
  description = "Enable S3 backup permissions"
  type        = bool
  default     = false
}
