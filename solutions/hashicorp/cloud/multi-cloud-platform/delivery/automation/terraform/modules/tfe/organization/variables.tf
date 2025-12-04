#------------------------------------------------------------------------------
# TFE Organization Module Variables
#------------------------------------------------------------------------------

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
}

variable "tfc" {
  description = "Terraform Cloud/Enterprise configuration"
  type = object({
    organization_name        = string
    admin_email              = string
    collaborator_auth_policy = string
    enable_cost_estimation   = bool
    enable_assessments       = bool
    default_execution_mode   = string
    github_enabled           = bool
    github_oauth_token       = string
    enable_agents            = bool
    default_aws_region       = string
  })
}

variable "vault_enabled" {
  description = "Whether Vault integration is enabled"
  type        = bool
  default     = false
}

variable "vault_endpoint" {
  description = "Vault endpoint URL"
  type        = string
  default     = ""
}
