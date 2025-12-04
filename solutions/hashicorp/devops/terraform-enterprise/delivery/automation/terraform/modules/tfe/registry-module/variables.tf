#------------------------------------------------------------------------------
# TFE Registry Module Variables
#------------------------------------------------------------------------------

variable "organization" {
  description = "TFE organization name"
  type        = string
}

variable "oauth_token_id" {
  description = "OAuth token ID for VCS access"
  type        = string
}

variable "registry_modules" {
  description = "Map of modules to register"
  type = map(object({
    vcs_repo        = string
    display_name    = string
    tests_enabled   = optional(bool, true)
    no_code_enabled = optional(bool, false)
  }))
  default = {}
}
