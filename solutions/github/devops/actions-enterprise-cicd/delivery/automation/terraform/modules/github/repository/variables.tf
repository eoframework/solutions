# GitHub Repository Module Variables

variable "repository_name" {
  description = "Repository name"
  type        = string
}

variable "create_repository" {
  description = "Whether to create the repository"
  type        = bool
  default     = false
}

variable "repository_id" {
  description = "Existing repository ID (if not creating)"
  type        = string
  default     = null
}

variable "description" {
  description = "Repository description"
  type        = string
  default     = ""
}

variable "visibility" {
  description = "Repository visibility (public, private, internal)"
  type        = string
  default     = "private"

  validation {
    condition     = contains(["public", "private", "internal"], var.visibility)
    error_message = "visibility must be public, private, or internal"
  }
}

variable "has_issues" {
  description = "Enable issues"
  type        = bool
  default     = true
}

variable "has_wiki" {
  description = "Enable wiki"
  type        = bool
  default     = false
}

variable "has_projects" {
  description = "Enable projects"
  type        = bool
  default     = false
}

variable "has_discussions" {
  description = "Enable discussions"
  type        = bool
  default     = false
}

variable "allow_merge_commit" {
  description = "Allow merge commits"
  type        = bool
  default     = true
}

variable "allow_squash_merge" {
  description = "Allow squash merges"
  type        = bool
  default     = true
}

variable "allow_rebase_merge" {
  description = "Allow rebase merges"
  type        = bool
  default     = false
}

variable "allow_auto_merge" {
  description = "Allow auto-merge"
  type        = bool
  default     = true
}

variable "delete_branch_on_merge" {
  description = "Delete branch after merge"
  type        = bool
  default     = true
}

variable "vulnerability_alerts" {
  description = "Enable vulnerability alerts"
  type        = bool
  default     = true
}

variable "archived" {
  description = "Archive the repository"
  type        = bool
  default     = false
}

variable "topics" {
  description = "Repository topics"
  type        = list(string)
  default     = []
}

variable "enable_branch_protection" {
  description = "Enable branch protection rules"
  type        = bool
  default     = true
}

variable "protected_branch_pattern" {
  description = "Branch pattern for protection rules"
  type        = string
  default     = "main"
}

variable "require_up_to_date_branch" {
  description = "Require branches to be up to date before merging"
  type        = bool
  default     = true
}

variable "required_status_checks" {
  description = "Required status checks"
  type        = list(string)
  default     = []
}

variable "dismiss_stale_reviews" {
  description = "Dismiss stale reviews"
  type        = bool
  default     = true
}

variable "require_code_owner_reviews" {
  description = "Require code owner reviews"
  type        = bool
  default     = true
}

variable "required_approving_review_count" {
  description = "Required approving review count"
  type        = number
  default     = 1

  validation {
    condition     = var.required_approving_review_count >= 0 && var.required_approving_review_count <= 6
    error_message = "required_approving_review_count must be between 0 and 6"
  }
}

variable "restrict_review_dismissals" {
  description = "Restrict who can dismiss reviews"
  type        = bool
  default     = false
}

variable "enforce_admins" {
  description = "Enforce restrictions for administrators"
  type        = bool
  default     = false
}

variable "require_signed_commits" {
  description = "Require signed commits"
  type        = bool
  default     = false
}

variable "require_linear_history" {
  description = "Require linear history"
  type        = bool
  default     = false
}

variable "require_conversation_resolution" {
  description = "Require conversation resolution before merging"
  type        = bool
  default     = true
}

variable "allows_deletions" {
  description = "Allow branch deletions"
  type        = bool
  default     = false
}

variable "allows_force_pushes" {
  description = "Allow force pushes"
  type        = bool
  default     = false
}

variable "environments" {
  description = "Environment configurations"
  type = map(object({
    wait_timer = optional(number, 0)
    reviewers = optional(object({
      teams = optional(list(number))
      users = optional(list(number))
    }))
    deployment_branch_policy = optional(object({
      protected_branches     = bool
      custom_branch_policies = bool
    }))
    secrets   = optional(map(string))
    variables = optional(map(string))
  }))
  default = {}
}

variable "repository_secrets" {
  description = "Repository-level secrets"
  type        = map(string)
  default     = {}
  sensitive   = true
}

variable "repository_variables" {
  description = "Repository-level variables"
  type        = map(string)
  default     = {}
}
