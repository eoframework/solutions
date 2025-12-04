#------------------------------------------------------------------------------
# Sentinel Policy Set Module Variables
#------------------------------------------------------------------------------

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "organization" {
  description = "TFC/TFE organization name"
  type        = string
}

variable "sentinel" {
  description = "Sentinel policy configuration"
  type = object({
    enabled                   = bool
    global_policies           = bool
    vcs_repo                  = string
    vcs_branch                = string
    oauth_token_id            = string
    policy_tool_version       = string
    enable_cost_policies      = bool
    cost_policy_enforcement   = string
    max_monthly_cost_increase = number
    enable_tag_policies       = bool
    tag_policy_enforcement    = string
    required_tags             = list(string)
    enable_provider_policies  = bool
    provider_policy_enforcement = string
    allowed_providers         = list(string)
    parameters = map(object({
      value     = string
      sensitive = bool
    }))
  })
}
