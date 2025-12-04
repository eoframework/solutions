# GitHub Organization Module Variables

variable "organization" {
  description = "GitHub organization name"
  type        = string
}

variable "allowed_actions" {
  description = "Actions allowed (all, local_only, selected)"
  type        = string
  default     = "selected"

  validation {
    condition     = contains(["all", "local_only", "selected"], var.allowed_actions)
    error_message = "allowed_actions must be one of: all, local_only, selected"
  }
}

variable "enabled_repositories" {
  description = "Which repositories can use Actions (all, none, selected)"
  type        = string
  default     = "all"

  validation {
    condition     = contains(["all", "none", "selected"], var.enabled_repositories)
    error_message = "enabled_repositories must be one of: all, none, selected"
  }
}

variable "github_owned_allowed" {
  description = "Allow GitHub-owned actions"
  type        = bool
  default     = true
}

variable "verified_allowed" {
  description = "Allow verified marketplace actions"
  type        = bool
  default     = true
}

variable "patterns_allowed" {
  description = "Allowed action patterns"
  type        = list(string)
  default     = []
}

variable "default_workflow_permissions" {
  description = "Default workflow permissions (read, write)"
  type        = string
  default     = "read"

  validation {
    condition     = contains(["read", "write"], var.default_workflow_permissions)
    error_message = "default_workflow_permissions must be read or write"
  }
}

variable "can_approve_pull_request_reviews" {
  description = "Allow workflows to approve pull requests"
  type        = bool
  default     = false
}

variable "runner_groups" {
  description = "Runner group configurations"
  type = map(object({
    name                       = string
    visibility                 = string
    repository_ids             = optional(list(number))
    allows_public_repositories = bool
  }))
  default = {}
}

variable "organization_secrets" {
  description = "Organization-level secrets"
  type = map(object({
    value          = string
    visibility     = string
    repository_ids = optional(list(number))
  }))
  default   = {}
  sensitive = true
}

variable "organization_variables" {
  description = "Organization-level variables (simple string map for convenience)"
  type        = map(string)
  default     = {}
}
