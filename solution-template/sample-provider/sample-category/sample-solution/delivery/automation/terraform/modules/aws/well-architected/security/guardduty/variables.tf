# AWS GuardDuty Module - Variables

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
# GuardDuty Settings
#------------------------------------------------------------------------------

variable "finding_publishing_frequency" {
  description = "Frequency of publishing findings"
  type        = string
  default     = "FIFTEEN_MINUTES"

  validation {
    condition     = contains(["FIFTEEN_MINUTES", "ONE_HOUR", "SIX_HOURS"], var.finding_publishing_frequency)
    error_message = "Finding publishing frequency must be: FIFTEEN_MINUTES, ONE_HOUR, or SIX_HOURS."
  }
}

variable "enable_s3_protection" {
  description = "Enable S3 data event monitoring"
  type        = bool
  default     = true
}

variable "enable_eks_protection" {
  description = "Enable EKS audit log monitoring"
  type        = bool
  default     = false
}

variable "enable_malware_protection" {
  description = "Enable malware scanning for EC2 instances"
  type        = bool
  default     = true
}

#------------------------------------------------------------------------------
# Findings Export
#------------------------------------------------------------------------------

variable "enable_s3_export" {
  description = "Export findings to S3 bucket"
  type        = bool
  default     = true
}

variable "findings_bucket_arn" {
  description = "S3 bucket ARN for findings (created if empty)"
  type        = string
  default     = ""
}

variable "findings_retention_days" {
  description = "Days to retain findings in S3"
  type        = number
  default     = 365
}

variable "kms_key_arn" {
  description = "KMS key ARN for encrypting findings"
  type        = string
}

#------------------------------------------------------------------------------
# Alerting
#------------------------------------------------------------------------------

variable "enable_alerts" {
  description = "Enable EventBridge alerts for high severity findings"
  type        = bool
  default     = true
}

variable "alert_severity_threshold" {
  description = "Minimum severity level to trigger alerts (1-10)"
  type        = number
  default     = 7

  validation {
    condition     = var.alert_severity_threshold >= 1 && var.alert_severity_threshold <= 10
    error_message = "Alert severity threshold must be between 1 and 10."
  }
}

variable "sns_topic_arn" {
  description = "SNS topic ARN for alerts"
  type        = string
  default     = ""
}

#------------------------------------------------------------------------------
# IP Lists (Optional)
#------------------------------------------------------------------------------

variable "trusted_ip_list_bucket" {
  description = "S3 bucket containing trusted IP list"
  type        = string
  default     = ""
}

variable "trusted_ip_list_key" {
  description = "S3 key for trusted IP list (empty to skip)"
  type        = string
  default     = ""
}

variable "threat_intel_list_bucket" {
  description = "S3 bucket containing threat intel list"
  type        = string
  default     = ""
}

variable "threat_intel_list_key" {
  description = "S3 key for threat intel list (empty to skip)"
  type        = string
  default     = ""
}
