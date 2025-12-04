#------------------------------------------------------------------------------
# TFE Run Task Module Variables
#------------------------------------------------------------------------------

variable "name_prefix" {
  description = "Name prefix for resources"
  type        = string
}

variable "organization" {
  description = "TFE organization name"
  type        = string
}

variable "integration" {
  description = "Integration configuration"
  type = object({
    github_org          = string
    github_vcs_enabled  = bool
    slack_enabled       = bool
    pagerduty_enabled   = bool
    servicenow_enabled  = optional(bool, false)
  })
}
