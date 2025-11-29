# Solution Security Module - Variables

#------------------------------------------------------------------------------
# Context from Core Module
#------------------------------------------------------------------------------

variable "name_prefix" {
  description = "Name prefix for resources (from core module)"
  type        = string
}

variable "common_tags" {
  description = "Common tags for resources (from core module)"
  type        = map(string)
}

variable "alb_arn" {
  description = "ALB ARN for WAF association (from core module)"
  type        = string
  default     = ""
}

#------------------------------------------------------------------------------
# KMS Configuration
#------------------------------------------------------------------------------

variable "enable_kms_key" {
  description = "Create dedicated KMS key for encryption"
  type        = bool
  default     = true
}

variable "kms_deletion_window" {
  description = "KMS key deletion window in days"
  type        = number
  default     = 30
}

variable "enable_key_rotation" {
  description = "Enable automatic KMS key rotation"
  type        = bool
  default     = true
}

#------------------------------------------------------------------------------
# WAF Configuration
#------------------------------------------------------------------------------

variable "enable_waf" {
  description = "Enable AWS WAF on ALB"
  type        = bool
  default     = false
}

variable "waf_rate_limit" {
  description = "WAF rate limit per IP (5-minute window)"
  type        = number
  default     = 2000
}

variable "waf_blocked_ips" {
  description = "List of IP addresses to block (CIDR notation)"
  type        = list(string)
  default     = []
}

variable "waf_blocked_countries" {
  description = "List of country codes to block (ISO 3166-1 alpha-2)"
  type        = list(string)
  default     = []
}

#------------------------------------------------------------------------------
# GuardDuty Configuration
#------------------------------------------------------------------------------

variable "enable_guardduty" {
  description = "Enable Amazon GuardDuty"
  type        = bool
  default     = false
}

#------------------------------------------------------------------------------
# CloudTrail Configuration
#------------------------------------------------------------------------------

variable "enable_cloudtrail" {
  description = "Enable AWS CloudTrail"
  type        = bool
  default     = true
}

variable "cloudtrail_retention_days" {
  description = "CloudTrail log retention in days"
  type        = number
  default     = 365
}
