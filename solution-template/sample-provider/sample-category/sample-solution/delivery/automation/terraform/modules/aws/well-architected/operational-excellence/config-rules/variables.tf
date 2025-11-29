# AWS Config Rules Module - Variables

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
# Config Recorder Settings
#------------------------------------------------------------------------------

variable "create_recorder" {
  description = "Create AWS Config recorder (set false if already exists in account)"
  type        = bool
  default     = true
}

variable "record_all_resources" {
  description = "Record all supported resource types"
  type        = bool
  default     = true
}

variable "include_global_resources" {
  description = "Include global resources (IAM, CloudFront)"
  type        = bool
  default     = true
}

variable "excluded_resource_types" {
  description = "Resource types to exclude from recording"
  type        = list(string)
  default     = []
}

variable "delivery_frequency" {
  description = "Config snapshot delivery frequency"
  type        = string
  default     = "TwentyFour_Hours"

  validation {
    condition     = contains(["One_Hour", "Three_Hours", "Six_Hours", "Twelve_Hours", "TwentyFour_Hours"], var.delivery_frequency)
    error_message = "Delivery frequency must be: One_Hour, Three_Hours, Six_Hours, Twelve_Hours, or TwentyFour_Hours."
  }
}

#------------------------------------------------------------------------------
# Storage Settings
#------------------------------------------------------------------------------

variable "config_bucket_name" {
  description = "S3 bucket for Config delivery (created if empty)"
  type        = string
  default     = ""
}

variable "config_s3_prefix" {
  description = "S3 key prefix for Config files"
  type        = string
  default     = "config"
}

variable "config_retention_days" {
  description = "Days to retain Config data in S3"
  type        = number
  default     = 365
}

variable "kms_key_arn" {
  description = "KMS key ARN for S3 bucket encryption"
  type        = string
  default     = ""
}

variable "sns_topic_arn" {
  description = "SNS topic ARN for Config notifications"
  type        = string
  default     = ""
}

#------------------------------------------------------------------------------
# Rule Categories
#------------------------------------------------------------------------------

variable "enable_security_rules" {
  description = "Enable security-related Config rules"
  type        = bool
  default     = true
}

variable "enable_reliability_rules" {
  description = "Enable reliability-related Config rules"
  type        = bool
  default     = true
}

variable "enable_operational_rules" {
  description = "Enable operational excellence Config rules"
  type        = bool
  default     = true
}

variable "enable_cost_rules" {
  description = "Enable cost optimization Config rules"
  type        = bool
  default     = true
}

#------------------------------------------------------------------------------
# Rule Parameters
#------------------------------------------------------------------------------

variable "min_backup_retention_days" {
  description = "Minimum backup retention days for DB backup rule"
  type        = number
  default     = 7
}
