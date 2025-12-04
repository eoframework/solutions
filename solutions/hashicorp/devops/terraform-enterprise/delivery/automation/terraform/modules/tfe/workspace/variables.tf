#------------------------------------------------------------------------------
# TFE Workspace Module Variables
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

variable "integration" {
  description = "VCS and external integration configuration"
  type = object({
    github_org          = string
    github_vcs_enabled  = bool
    slack_enabled       = bool
    pagerduty_enabled   = bool
    servicenow_enabled  = optional(bool, false)
  })
}

variable "environment" {
  description = "Environment name (prod, test, dr)"
  type        = string
}
