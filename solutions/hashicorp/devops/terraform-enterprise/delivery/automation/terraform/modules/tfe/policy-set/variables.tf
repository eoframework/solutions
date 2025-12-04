#------------------------------------------------------------------------------
# TFE Policy Set Module Variables
#------------------------------------------------------------------------------

variable "name_prefix" {
  description = "Name prefix for resources"
  type        = string
}

variable "organization" {
  description = "TFE organization name"
  type        = string
}

variable "sentinel" {
  description = "Sentinel policy configuration"
  type = object({
    enabled           = bool
    policy_count      = number
    enforcement_level = string
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
