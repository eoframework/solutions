#------------------------------------------------------------------------------
# Consolidated DR Module - Variables
#------------------------------------------------------------------------------

variable "name_prefix" {
  description = "Prefix for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name (prod, test, dr)"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "kms_key_arn" {
  description = "KMS key ARN for encrypting backups"
  type        = string
}

variable "sns_topic_arn" {
  description = "SNS topic ARN for backup notifications"
  type        = string
  default     = ""
}

variable "dr_region" {
  description = "DR region for cross-region replication"
  type        = string
  default     = "us-west-2"
}

#------------------------------------------------------------------------------
# Consolidated DR Configuration
#------------------------------------------------------------------------------
variable "dr" {
  description = "Disaster Recovery configuration - strategy, replication, vault, and backup settings"
  type = object({
    # Master DR toggle and strategy
    enabled       = optional(bool, false)
    strategy      = optional(string, "ACTIVE_PASSIVE")
    rto_minutes   = optional(number, 240)
    rpo_minutes   = optional(number, 60)
    failover_mode = optional(string, "manual")

    # Cross-region replication settings (production)
    replication_enabled = optional(bool, false)

    # DR vault settings (DR environment)
    vault_enabled     = optional(bool, false)
    vault_enable_lock = optional(bool, false)

    # Backup retention settings
    backup_retention_days       = optional(number, 30)
    backup_local_retention_days = optional(number, 7)
    enable_weekly_backup        = optional(bool, true)
    weekly_backup_retention_days = optional(number, 90)

    # DR operations
    test_schedule      = optional(string, "")
    notification_email = optional(string, "")
  })

  default = {
    enabled = false
  }
}
