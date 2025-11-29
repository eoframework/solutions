# AWS Backup Plans Module - Variables

#------------------------------------------------------------------------------
# Naming & Tags
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

#------------------------------------------------------------------------------
# Encryption
#------------------------------------------------------------------------------

variable "kms_key_arn" {
  description = "KMS key ARN for backup vault encryption"
  type        = string
}

variable "dr_kms_key_arn" {
  description = "KMS key ARN for DR region backup vault"
  type        = string
  default     = ""
}

#------------------------------------------------------------------------------
# Daily Backup Settings
#------------------------------------------------------------------------------

variable "daily_backup_schedule" {
  description = "Cron expression for daily backup schedule (UTC)"
  type        = string
  default     = "cron(0 5 * * ? *)" # 5 AM UTC daily
}

variable "daily_retention_days" {
  description = "Days to retain daily backups"
  type        = number
  default     = 30
}

variable "enable_continuous_backup" {
  description = "Enable continuous backup for point-in-time recovery"
  type        = bool
  default     = false
}

#------------------------------------------------------------------------------
# Weekly Backup Settings
#------------------------------------------------------------------------------

variable "enable_weekly_backup" {
  description = "Enable weekly backup rule"
  type        = bool
  default     = true
}

variable "weekly_backup_schedule" {
  description = "Cron expression for weekly backup (UTC)"
  type        = string
  default     = "cron(0 5 ? * SUN *)" # Sunday 5 AM UTC
}

variable "weekly_retention_days" {
  description = "Days to retain weekly backups"
  type        = number
  default     = 90
}

#------------------------------------------------------------------------------
# Monthly Backup Settings
#------------------------------------------------------------------------------

variable "enable_monthly_backup" {
  description = "Enable monthly backup rule"
  type        = bool
  default     = true
}

variable "monthly_backup_schedule" {
  description = "Cron expression for monthly backup (UTC)"
  type        = string
  default     = "cron(0 5 1 * ? *)" # 1st of month 5 AM UTC
}

variable "monthly_retention_days" {
  description = "Days to retain monthly backups"
  type        = number
  default     = 365
}

variable "monthly_cold_storage_days" {
  description = "Days before moving monthly backups to cold storage"
  type        = number
  default     = 90
}

#------------------------------------------------------------------------------
# Cross-Region Copy (DR)
#------------------------------------------------------------------------------

variable "enable_cross_region_copy" {
  description = "Enable cross-region copy for disaster recovery"
  type        = bool
  default     = false
}

variable "dr_retention_days" {
  description = "Days to retain backups in DR region"
  type        = number
  default     = 30
}

#------------------------------------------------------------------------------
# Resource Selection
#------------------------------------------------------------------------------

variable "enable_tag_based_selection" {
  description = "Select resources by tag"
  type        = bool
  default     = true
}

variable "backup_tag_key" {
  description = "Tag key for backup selection"
  type        = string
  default     = "Backup"
}

variable "backup_tag_value" {
  description = "Tag value for backup selection"
  type        = string
  default     = "true"
}

variable "resource_arns" {
  description = "Specific resource ARNs to backup"
  type        = list(string)
  default     = []
}

#------------------------------------------------------------------------------
# Additional Features
#------------------------------------------------------------------------------

variable "enable_windows_vss" {
  description = "Enable Windows VSS for application-consistent backups"
  type        = bool
  default     = false
}

variable "enable_s3_backup" {
  description = "Enable S3 bucket backup support"
  type        = bool
  default     = false
}

variable "enable_vault_policy" {
  description = "Enable vault access policy"
  type        = bool
  default     = true
}

#------------------------------------------------------------------------------
# Vault Lock (Compliance)
#------------------------------------------------------------------------------

variable "enable_vault_lock" {
  description = "Enable vault lock for compliance (WORM)"
  type        = bool
  default     = false
}

variable "vault_lock_min_retention" {
  description = "Minimum retention days for vault lock"
  type        = number
  default     = 7
}

variable "vault_lock_max_retention" {
  description = "Maximum retention days for vault lock"
  type        = number
  default     = 365
}

variable "vault_lock_changeable_days" {
  description = "Days before vault lock becomes immutable"
  type        = number
  default     = 3
}

#------------------------------------------------------------------------------
# Notifications
#------------------------------------------------------------------------------

variable "sns_topic_arn" {
  description = "SNS topic ARN for backup notifications"
  type        = string
  default     = ""
}

variable "notification_events" {
  description = "Backup vault events to notify on"
  type        = list(string)
  default = [
    "BACKUP_JOB_STARTED",
    "BACKUP_JOB_COMPLETED",
    "BACKUP_JOB_FAILED",
    "RESTORE_JOB_STARTED",
    "RESTORE_JOB_COMPLETED",
    "RESTORE_JOB_FAILED"
  ]
}
