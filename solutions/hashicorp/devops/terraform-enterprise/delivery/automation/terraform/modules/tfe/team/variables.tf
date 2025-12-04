#------------------------------------------------------------------------------
# TFE Team Module Variables
#------------------------------------------------------------------------------

variable "organization" {
  description = "TFE organization name"
  type        = string
}

variable "tfe" {
  description = "TFE configuration"
  type = object({
    organization     = string
    hostname         = string
    license_path     = optional(string, "")
    admin_email      = string
    operational_mode = string
    concurrent_runs  = number
    workspace_count  = number
    user_count       = number
  })
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
