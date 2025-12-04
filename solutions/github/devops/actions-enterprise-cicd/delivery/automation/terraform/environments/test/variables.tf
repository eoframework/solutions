#------------------------------------------------------------------------------
# GitHub Actions Enterprise CI/CD - Variables
#------------------------------------------------------------------------------
# Uses EO Framework object-based variable structure for:
# - Solution and ownership metadata
# - GitHub and AWS configuration
# - Self-hosted runners
# - Workflow configuration
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Project Configuration
#------------------------------------------------------------------------------
variable "solution" {
  description = "Solution configuration"
  type = object({
    name          = string
    abbr          = string
    version       = string
    provider_name = string
    category_name = string
  })
}

variable "ownership" {
  description = "Ownership and billing configuration"
  type = object({
    cost_center  = string
    owner_email  = string
    project_code = string
  })
}

#------------------------------------------------------------------------------
# GitHub Configuration
#------------------------------------------------------------------------------
variable "github" {
  description = "GitHub organization configuration"
  type = object({
    enterprise_url     = string
    organization_name  = string
    enterprise_license = string
    actions_minutes    = number
  })
}

#------------------------------------------------------------------------------
# Authentication Configuration
#------------------------------------------------------------------------------
variable "auth" {
  description = "Authentication configuration"
  type = object({
    api_token = string
  })
  sensitive = true
}

#------------------------------------------------------------------------------
# AWS Configuration
#------------------------------------------------------------------------------
variable "aws" {
  description = "AWS configuration"
  type = object({
    account_id = string
    region     = string
  })
}

#------------------------------------------------------------------------------
# Self-Hosted Runners Configuration
#------------------------------------------------------------------------------
variable "runners" {
  description = "Self-hosted runners configuration"
  type = object({
    vpc_id              = string
    subnet_ids          = string
    security_group_id   = string
    instance_type_linux = string
    instance_type_windows = string
    count_linux         = number
    count_windows       = number
    asg_min_linux       = number
    asg_max_linux       = number
    asg_min_windows     = number
    asg_max_windows     = number
    scale_up_threshold  = number
    scale_down_cooldown = number
    ami_linux           = string
    ami_windows         = string
  })
}

#------------------------------------------------------------------------------
# OIDC Configuration
#------------------------------------------------------------------------------
variable "oidc" {
  description = "GitHub OIDC configuration for AWS"
  type = object({
    provider_arn = string
    role_deploy  = string
  })
}

#------------------------------------------------------------------------------
# Container Configuration
#------------------------------------------------------------------------------
variable "container" {
  description = "Container registry configuration"
  type = object({
    ecr_registry_url     = string
    ghcr_registry_url    = string
    image_retention_days = number
  })
}

#------------------------------------------------------------------------------
# Kubernetes Configuration
#------------------------------------------------------------------------------
variable "kubernetes" {
  description = "Kubernetes cluster configuration"
  type = object({
    eks_cluster_name = string
  })
}

#------------------------------------------------------------------------------
# Workflow Configuration
#------------------------------------------------------------------------------
variable "workflows" {
  description = "Workflow configuration"
  type = object({
    template_repo      = string
    build_timeout      = number
    artifact_retention = number
    cache_key_prefix   = string
  })
}

#------------------------------------------------------------------------------
# Governance Configuration
#------------------------------------------------------------------------------
variable "governance" {
  description = "Governance and policy configuration"
  type = object({
    branch_protection_enabled   = bool
    environment_reviewers_count = number
    environment_wait_timer      = number
  })
}

#------------------------------------------------------------------------------
# Security Configuration
#------------------------------------------------------------------------------
variable "security" {
  description = "Security configuration"
  type = object({
    enable_security_scanning = bool
    enable_secret_scanning   = bool
  })
}

#------------------------------------------------------------------------------
# Monitoring Configuration
#------------------------------------------------------------------------------
variable "monitoring" {
  description = "Monitoring configuration"
  type = object({
    datadog_api_key           = string
    datadog_app_key           = string
    pagerduty_integration_key = string
  })
  sensitive = true
}

#------------------------------------------------------------------------------
# Notifications Configuration
#------------------------------------------------------------------------------
variable "notifications" {
  description = "Notification configuration"
  type = object({
    slack_webhook_url = string
    teams_webhook_url = string
  })
  sensitive = true
}

#------------------------------------------------------------------------------
# Performance Configuration
#------------------------------------------------------------------------------
variable "performance" {
  description = "Performance targets"
  type = object({
    pipeline_target_duration  = number
    deployment_success_target = number
  })
}

#------------------------------------------------------------------------------
# DR Configuration
#------------------------------------------------------------------------------
variable "dr" {
  description = "Disaster recovery configuration"
  type = object({
    enabled           = bool
    failover_priority = number
  })
}

#------------------------------------------------------------------------------
# Repository Access (Complex Types)
#------------------------------------------------------------------------------
variable "production_repository_ids" {
  description = "Repository IDs with access to production runner group"
  type        = list(number)
  default     = []
}

variable "security_repository_ids" {
  description = "Repository IDs with access to security runner group"
  type        = list(number)
  default     = []
}

variable "production_reviewer_teams" {
  description = "Team IDs for production environment reviewers"
  type        = list(number)
  default     = []
}

variable "production_reviewer_users" {
  description = "User IDs for production environment reviewers"
  type        = list(number)
  default     = []
}

variable "create_github_repo" {
  description = "Whether to create .github repository"
  type        = bool
  default     = false
}

variable "actions_allowed_patterns" {
  description = "Allowed action patterns"
  type        = list(string)
  default = [
    "actions/*",
    "github/*",
    "hashicorp/*",
    "aws-actions/*",
    "azure/*",
    "docker/*"
  ]
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
