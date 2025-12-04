#------------------------------------------------------------------------------
# GitHub Organization Module Variables
#------------------------------------------------------------------------------

variable "organization_name" {
  description = "GitHub organization name"
  type        = string
}

variable "billing_email" {
  description = "Billing email for the organization"
  type        = string
}

variable "company_name" {
  description = "Company name"
  type        = string
  default     = ""
}

variable "blog_url" {
  description = "Organization blog URL"
  type        = string
  default     = ""
}

variable "email" {
  description = "Organization email"
  type        = string
  default     = ""
}

variable "twitter_username" {
  description = "Organization Twitter username"
  type        = string
  default     = ""
}

variable "location" {
  description = "Organization location"
  type        = string
  default     = ""
}

variable "description" {
  description = "Organization description"
  type        = string
  default     = ""
}

variable "has_organization_projects" {
  description = "Enable organization projects"
  type        = bool
  default     = true
}

variable "has_repository_projects" {
  description = "Enable repository projects"
  type        = bool
  default     = true
}

variable "default_repository_permission" {
  description = "Default repository permission for members"
  type        = string
  default     = "read"
  validation {
    condition     = contains(["read", "write", "admin", "none"], var.default_repository_permission)
    error_message = "Must be one of: read, write, admin, none"
  }
}

variable "members_can_create_repositories" {
  description = "Allow members to create repositories"
  type        = bool
  default     = false
}

variable "members_can_create_public_repositories" {
  description = "Allow members to create public repositories"
  type        = bool
  default     = false
}

variable "members_can_create_private_repositories" {
  description = "Allow members to create private repositories"
  type        = bool
  default     = false
}

variable "members_can_create_internal_repositories" {
  description = "Allow members to create internal repositories"
  type        = bool
  default     = false
}

variable "members_can_create_pages" {
  description = "Allow members to create GitHub Pages"
  type        = bool
  default     = false
}

variable "members_can_create_public_pages" {
  description = "Allow members to create public GitHub Pages"
  type        = bool
  default     = false
}

variable "members_can_create_private_pages" {
  description = "Allow members to create private GitHub Pages"
  type        = bool
  default     = false
}

variable "members_can_fork_private_repositories" {
  description = "Allow members to fork private repositories"
  type        = bool
  default     = false
}

variable "web_commit_signoff_required" {
  description = "Require commit signoff for web-based commits"
  type        = bool
  default     = true
}

#------------------------------------------------------------------------------
# GitHub Advanced Security Settings
#------------------------------------------------------------------------------

variable "advanced_security_enabled" {
  description = "Enable Advanced Security for new repositories"
  type        = bool
  default     = true
}

variable "dependabot_alerts_enabled" {
  description = "Enable Dependabot alerts for new repositories"
  type        = bool
  default     = true
}

variable "dependabot_security_updates_enabled" {
  description = "Enable Dependabot security updates for new repositories"
  type        = bool
  default     = true
}

variable "dependency_graph_enabled" {
  description = "Enable dependency graph for new repositories"
  type        = bool
  default     = true
}

variable "secret_scanning_enabled" {
  description = "Enable secret scanning for new repositories"
  type        = bool
  default     = true
}

variable "secret_scanning_push_protection_enabled" {
  description = "Enable secret scanning push protection for new repositories"
  type        = bool
  default     = true
}

#------------------------------------------------------------------------------
# Security Manager Teams
#------------------------------------------------------------------------------

variable "security_manager_teams" {
  description = "Teams to designate as security managers"
  type = map(object({
    name        = string
    description = string
    privacy     = string
  }))
  default = {}
}

#------------------------------------------------------------------------------
# Webhooks
#------------------------------------------------------------------------------

variable "webhooks" {
  description = "Organization webhooks for security events"
  type = map(object({
    active       = bool
    events       = list(string)
    url          = string
    content_type = string
    insecure_ssl = bool
    secret       = string
  }))
  default = {}
}

#------------------------------------------------------------------------------
# Organization Rulesets
#------------------------------------------------------------------------------

variable "rulesets" {
  description = "Organization rulesets for branch protection"
  type = map(object({
    name                              = string
    target                            = string
    enforcement                       = string
    ref_name_include                  = list(string)
    ref_name_exclude                  = list(string)
    repository_name_include           = list(string)
    repository_name_exclude           = list(string)
    bypass_actor_id                   = number
    bypass_actor_type                 = string
    bypass_mode                       = string
    require_pull_request              = bool
    required_approving_review_count   = number
    dismiss_stale_reviews             = bool
    require_code_owner_review         = bool
    require_last_push_approval        = bool
    required_review_thread_resolution = bool
    required_status_checks            = bool
    strict_required_status_checks     = bool
    require_signed_commits            = bool
    require_linear_history            = bool
    allow_force_pushes                = bool
    allow_deletions                   = bool
  }))
  default = {}
}
