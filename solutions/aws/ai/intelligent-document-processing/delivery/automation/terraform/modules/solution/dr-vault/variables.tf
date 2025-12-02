#------------------------------------------------------------------------------
# IDP DR Vault Module - Variables
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
# Tags
#------------------------------------------------------------------------------

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

#------------------------------------------------------------------------------
# DR Configuration (Grouped Object)
#------------------------------------------------------------------------------

variable "dr" {
  description = "DR vault configuration from consolidated dr variable"
  type = object({
    # Enable/disable DR vault
    vault_enabled = bool

    # KMS settings
    vault_kms_deletion_window_days = optional(number, 30)

    # S3 lifecycle settings
    vault_transition_to_ia_days              = optional(number, 30)
    vault_noncurrent_version_expiration_days = optional(number, 90)

    # Vault lock settings (for compliance/immutable backups)
    vault_enable_lock = optional(bool, false)
  })
}
