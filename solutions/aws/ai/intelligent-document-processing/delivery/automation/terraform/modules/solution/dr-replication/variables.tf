#------------------------------------------------------------------------------
# IDP DR Replication Module - Variables
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Project Configuration
#------------------------------------------------------------------------------

variable "project" {
  description = "Project configuration"
  type = object({
    name        = string
    environment = string
  })
}

#------------------------------------------------------------------------------
# Source Resources (Production)
#------------------------------------------------------------------------------

variable "source_bucket_id" {
  description = "Source S3 bucket ID (name)"
  type        = string
}

variable "source_bucket_arn" {
  description = "Source S3 bucket ARN"
  type        = string
}

variable "source_bucket_versioning_enabled" {
  description = "Whether versioning is enabled on source bucket (required for CRR)"
  type        = bool
  default     = true
}

variable "results_table_arn" {
  description = "ARN of the results DynamoDB table"
  type        = string
}

variable "jobs_table_arn" {
  description = "ARN of the jobs DynamoDB table"
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key ARN in source region"
  type        = string
}

variable "sns_topic_arn" {
  description = "SNS topic ARN for notifications"
  type        = string
  default     = null
}

#------------------------------------------------------------------------------
# DR Configuration (Grouped Object)
#------------------------------------------------------------------------------

variable "dr" {
  description = "DR replication configuration from consolidated dr variable"
  type = object({
    # Enable/disable DR replication
    enabled = bool

    # DR region and resources
    dr_region      = string
    dr_bucket_arn  = string
    dr_bucket_id   = string
    dr_kms_key_arn = string
    dr_vault_arn   = string

    # S3 replication settings
    storage_replication_class       = optional(string, "STANDARD")
    enable_replication_time_control = optional(bool, true)

    # Backup settings
    backup_local_retention_days  = optional(number, 7)
    backup_retention_days        = optional(number, 30)
    enable_weekly_backup         = optional(bool, true)
    weekly_backup_retention_days = optional(number, 90)
  })
}

#------------------------------------------------------------------------------
# Tags
#------------------------------------------------------------------------------

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
