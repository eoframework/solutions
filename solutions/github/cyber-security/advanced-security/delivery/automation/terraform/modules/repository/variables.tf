#------------------------------------------------------------------------------
# GitHub Repository Module Variables
#------------------------------------------------------------------------------

variable "repositories" {
  description = "Map of repositories to configure"
  type = map(object({
    # Security Features
    advanced_security_enabled                 = bool
    secret_scanning_enabled                   = bool
    secret_scanning_push_protection_enabled   = bool
    dependabot_security_updates_enabled       = bool

    # Branch Protection
    branch_protection_enabled           = bool
    protected_branch                    = string
    strict_status_checks                = bool
    required_status_contexts            = list(string)
    dismiss_stale_reviews               = bool
    require_code_owner_reviews          = bool
    required_approving_review_count     = number
    dismissal_users                     = list(string)
    dismissal_teams                     = list(string)
    restriction_users                   = list(string)
    restriction_teams                   = list(string)
    restriction_apps                    = list(string)
    enforce_admins                      = bool
    require_signed_commits              = bool
    require_conversation_resolution     = bool

    # Configuration Files
    codeql_config_enabled       = bool
    codeql_config_content       = string
    dependabot_config_enabled   = bool
    dependabot_config_content   = string
    security_policy_enabled     = bool
    security_policy_content     = string
  }))
  default = {}
}

variable "commit_author" {
  description = "Commit author for configuration files"
  type        = string
  default     = "GitHub Advanced Security Automation"
}

variable "commit_email" {
  description = "Commit email for configuration files"
  type        = string
  default     = "ghas-automation@example.com"
}

variable "repository_secrets" {
  description = "Repository secrets for GitHub Actions"
  type = map(object({
    repository      = string
    secret_name     = string
    plaintext_value = string
  }))
  default   = {}
  sensitive = true
}

variable "repository_environments" {
  description = "Repository environments configuration"
  type = map(object({
    repository             = string
    environment            = string
    protected_branches     = bool
    custom_branch_policies = bool
    reviewer_users         = list(number)
    reviewer_teams         = list(number)
    wait_timer             = number
  }))
  default = {}
}
