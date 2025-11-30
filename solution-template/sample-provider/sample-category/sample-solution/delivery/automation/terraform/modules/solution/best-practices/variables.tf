#------------------------------------------------------------------------------
# Best Practices Module - Variables
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Common Variables
#------------------------------------------------------------------------------

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
}

variable "environment" {
  description = "Environment name (prod, test, dr)"
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key ARN for encryption"
  type        = string
}

variable "sns_topic_arn" {
  description = "SNS topic ARN for notifications"
  type        = string
}

#------------------------------------------------------------------------------
# Optional Bucket Names (auto-generated if empty)
#------------------------------------------------------------------------------

variable "config_bucket_name" {
  description = "S3 bucket for AWS Config (auto-generated if empty)"
  type        = string
  default     = ""
}

variable "guardduty_findings_bucket" {
  description = "S3 bucket for GuardDuty findings (auto-generated if empty)"
  type        = string
  default     = ""
}

variable "dr_kms_key_arn" {
  description = "KMS key ARN for DR region backup vault"
  type        = string
  default     = ""
}

#------------------------------------------------------------------------------
# Config Rules Configuration
#------------------------------------------------------------------------------

variable "config_rules" {
  description = "AWS Config rules configuration"
  type = object({
    enabled                   = bool
    enable_recorder           = bool
    retention_days            = number
    # Rule Categories
    enable_security_rules     = optional(bool, true)
    enable_reliability_rules  = optional(bool, true)
    enable_operational_rules  = optional(bool, true)
    enable_cost_rules         = optional(bool, true)
    # Rule Parameters
    min_backup_retention_days = optional(number, 7)
    # Config Recorder Settings
    record_all_resources      = optional(bool, true)
    include_global_resources  = optional(bool, true)
    excluded_resource_types   = optional(list(string), [])
    delivery_frequency        = optional(string, "TwentyFour_Hours")
  })
}

#------------------------------------------------------------------------------
# GuardDuty Enhanced Configuration
#------------------------------------------------------------------------------

variable "guardduty_enhanced" {
  description = "Enhanced GuardDuty configuration"
  type = object({
    enabled                   = bool
    enable_eks_protection     = bool
    enable_malware_protection = bool
    severity_threshold        = number
    # Findings Export
    enable_s3_export          = optional(bool, true)
    findings_retention_days   = optional(number, 365)
  })
}

#------------------------------------------------------------------------------
# Backup Configuration
#------------------------------------------------------------------------------

variable "backup" {
  description = "AWS Backup configuration"
  type = object({
    enabled                    = bool
    # Daily Backups
    daily_schedule             = string
    daily_retention            = number
    # Weekly Backups
    enable_weekly              = optional(bool, true)
    weekly_schedule            = string
    weekly_retention           = number
    # Monthly Backups
    enable_monthly             = optional(bool, true)
    monthly_schedule           = string
    monthly_retention          = number
    cold_storage_days          = number
    # Cross-Region DR
    enable_cross_region        = bool
    dr_retention               = number
    # Resource Selection
    enable_tag_selection       = optional(bool, true)
    backup_tag_key             = optional(string, "Backup")
    backup_tag_value           = optional(string, "true")
    resource_arns              = optional(list(string), [])
    # Advanced Options
    enable_continuous          = bool
    enable_windows_vss         = bool
    enable_s3_backup           = optional(bool, false)
    enable_vault_policy        = optional(bool, true)
    # Compliance (WORM)
    enable_vault_lock          = bool
    vault_lock_min_retention   = number
    vault_lock_max_retention   = number
    vault_lock_changeable_days = number
    # Notifications
    notification_events        = optional(list(string), [
      "BACKUP_JOB_STARTED",
      "BACKUP_JOB_COMPLETED",
      "BACKUP_JOB_FAILED",
      "RESTORE_JOB_STARTED",
      "RESTORE_JOB_COMPLETED",
      "RESTORE_JOB_FAILED"
    ])
  })
}

#------------------------------------------------------------------------------
# Budget Configuration
#------------------------------------------------------------------------------

variable "budget" {
  description = "AWS Budgets configuration"
  type = object({
    enabled                      = bool
    # Monthly Cost Budget
    enable_cost_budget           = optional(bool, true)
    monthly_amount               = number
    budget_currency              = optional(string, "USD")
    budget_time_unit             = optional(string, "MONTHLY")
    # Alert Thresholds
    alert_thresholds             = list(number)
    enable_forecast_alert        = optional(bool, true)
    forecast_threshold           = number
    # Notification Settings
    notification_comparison      = optional(string, "GREATER_THAN")
    notification_threshold_type  = optional(string, "PERCENTAGE")
    notification_type            = optional(string, "ACTUAL")
    # Alert Recipients
    alert_emails                 = list(string)
    # Service-Specific Budgets
    enable_service_budgets       = bool
    ec2_budget_amount            = number
    rds_budget_amount            = number
    data_transfer_budget_amount  = number
    service_alert_threshold      = optional(number, 80)
    # Usage Budget
    enable_usage_budget          = bool
    ec2_usage_hours_limit        = number
    # Budget Actions
    enable_actions               = bool
    action_approval              = string
    action_threshold             = number
    ec2_instances_to_stop        = list(string)
  })
}
