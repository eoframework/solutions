#------------------------------------------------------------------------------
# Security Module Variables
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

variable "security" {
  description = "Security configuration"
  type = object({
    enable_kms_encryption = bool
    kms_deletion_window   = number
    enable_waf            = bool
    waf_rate_limit        = number
    enable_guardduty      = bool
    enable_cloudtrail     = bool
    sso_enabled           = bool
    mfa_required          = bool
  })
}
