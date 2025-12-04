#------------------------------------------------------------------------------
# Security Module - Variables
#------------------------------------------------------------------------------

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
}

variable "security" {
  description = "Security configuration object"
  type = object({
    enable_kms_encryption     = bool
    kms_deletion_window       = number
    enable_waf                = bool
    waf_rate_limit            = number
    enable_guardduty          = bool
    enable_cloudtrail         = bool
    cloudtrail_retention_days = number
    sso_enabled               = bool
    mfa_required              = bool
  })
}
