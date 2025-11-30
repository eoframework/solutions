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
    enabled         = bool
    enable_recorder = bool
    retention_days  = number
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
  })
}

#------------------------------------------------------------------------------
# Backup Configuration
#------------------------------------------------------------------------------

variable "backup" {
  description = "AWS Backup configuration"
  type = object({
    enabled                    = bool
    daily_schedule             = string
    daily_retention            = number
    weekly_schedule            = string
    weekly_retention           = number
    monthly_schedule           = string
    monthly_retention          = number
    cold_storage_days          = number
    enable_cross_region        = bool
    dr_retention               = number
    enable_continuous          = bool
    enable_windows_vss         = bool
    enable_vault_lock          = bool
    vault_lock_min_retention   = number
    vault_lock_max_retention   = number
    vault_lock_changeable_days = number
  })
}

#------------------------------------------------------------------------------
# Budget Configuration
#------------------------------------------------------------------------------

variable "budget" {
  description = "AWS Budgets configuration"
  type = object({
    enabled                     = bool
    monthly_amount              = number
    alert_thresholds            = list(number)
    forecast_threshold          = number
    alert_emails                = list(string)
    enable_service_budgets      = bool
    ec2_budget_amount           = number
    rds_budget_amount           = number
    data_transfer_budget_amount = number
    enable_usage_budget         = bool
    ec2_usage_hours_limit       = number
    enable_actions              = bool
    action_approval             = string
    action_threshold            = number
    ec2_instances_to_stop       = list(string)
  })
}
