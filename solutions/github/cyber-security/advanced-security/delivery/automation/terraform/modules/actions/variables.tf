#------------------------------------------------------------------------------
# GitHub Actions Module Variables
#------------------------------------------------------------------------------

variable "allowed_actions" {
  description = "Actions allowed in the organization (all, local_only, selected)"
  type        = string
  default     = "selected"
  validation {
    condition     = contains(["all", "local_only", "selected"], var.allowed_actions)
    error_message = "Must be one of: all, local_only, selected"
  }
}

variable "enabled_repositories" {
  description = "Which repositories can use Actions (all, none, selected)"
  type        = string
  default     = "all"
  validation {
    condition     = contains(["all", "none", "selected"], var.enabled_repositories)
    error_message = "Must be one of: all, none, selected"
  }
}

variable "github_owned_allowed" {
  description = "Allow GitHub-owned actions"
  type        = bool
  default     = true
}

variable "verified_allowed" {
  description = "Allow verified creator actions"
  type        = bool
  default     = true
}

variable "patterns_allowed" {
  description = "Allowed action patterns"
  type        = list(string)
  default     = []
}

variable "enabled_repository_ids" {
  description = "Repository IDs that can use Actions (when enabled_repositories is 'selected')"
  type        = list(number)
  default     = []
}

variable "organization_secrets" {
  description = "Organization-level secrets for GitHub Actions"
  type = map(object({
    visibility              = string
    plaintext_value         = string
    selected_repository_ids = optional(list(number))
  }))
  default   = {}
  sensitive = true
}

variable "organization_variables" {
  description = "Organization-level variables for GitHub Actions"
  type = map(object({
    visibility              = string
    value                   = string
    selected_repository_ids = optional(list(number))
  }))
  default = {}
}

variable "runner_groups" {
  description = "Self-hosted runner groups (Enterprise only)"
  type = map(object({
    name                       = string
    visibility                 = string
    selected_repository_ids    = list(number)
    allows_public_repositories = bool
    restricted_to_workflows    = bool
    selected_workflows         = list(string)
  }))
  default = {}
}
