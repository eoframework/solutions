#------------------------------------------------------------------------------
# GitHub Advanced Security - Variables
#------------------------------------------------------------------------------
# Uses EO Framework object-based variable structure for:
# - Solution and ownership metadata
# - GitHub configuration
# - Security feature configuration
# - Integration settings
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
    ghas_committers    = number
    total_repositories = number
    total_developers   = number
  })
}

#------------------------------------------------------------------------------
# Authentication Configuration
#------------------------------------------------------------------------------
variable "auth" {
  description = "Authentication configuration"
  type = object({
    api_token        = string
    app_id           = optional(string, "")
    app_private_key  = optional(string, "")
    saml_entity_id   = optional(string, "")
    saml_sso_url     = optional(string, "")
    saml_certificate = optional(string, "")
    mfa_enforcement  = string
  })
  sensitive = true
}

#------------------------------------------------------------------------------
# CodeQL Configuration
#------------------------------------------------------------------------------
variable "codeql" {
  description = "CodeQL analysis configuration"
  type = object({
    enabled              = bool
    languages            = string
    query_suites         = string
    schedule             = string
    timeout_minutes      = number
    ram_mb               = number
    threads              = number
    custom_queries_repo  = string
    custom_queries_path  = string
    custom_queries_count = number
  })
}

#------------------------------------------------------------------------------
# Secret Scanning Configuration
#------------------------------------------------------------------------------
variable "secret_scanning" {
  description = "Secret scanning configuration"
  type = object({
    enabled                 = bool
    push_protection_enabled = bool
    custom_patterns_count   = number
    bypass_workflow         = string
    alert_threshold         = number
  })
}

#------------------------------------------------------------------------------
# Dependabot Configuration
#------------------------------------------------------------------------------
variable "dependabot" {
  description = "Dependabot configuration"
  type = object({
    enabled            = bool
    security_updates   = bool
    version_updates    = bool
    schedule           = string
    package_ecosystems = string
  })
}

#------------------------------------------------------------------------------
# Branch Protection Configuration
#------------------------------------------------------------------------------
variable "branch_protection" {
  description = "Branch protection configuration"
  type = object({
    enabled                 = bool
    require_codeql_pass     = bool
    required_reviews        = number
    require_codeowner_review = bool
    dismiss_stale_reviews   = bool
    require_linear_history  = bool
    allow_force_pushes      = bool
    allow_deletions         = bool
  })
}

#------------------------------------------------------------------------------
# Vulnerability SLA Configuration
#------------------------------------------------------------------------------
variable "sla" {
  description = "Vulnerability SLA configuration (hours)"
  type = object({
    critical_hours = number
    high_hours     = number
    medium_hours   = number
    low_hours      = number
  })
}

#------------------------------------------------------------------------------
# Detection Configuration
#------------------------------------------------------------------------------
variable "detection" {
  description = "Detection accuracy configuration"
  type = object({
    confidence_threshold     = number
    accuracy_target          = number
    false_positive_threshold = number
  })
}

#------------------------------------------------------------------------------
# Integration Configuration
#------------------------------------------------------------------------------
variable "integration" {
  description = "SIEM and ticketing integration configuration"
  type = object({
    siem_webhook_url       = string
    siem_webhook_secret    = string
    siem_event_types       = string
    siem_platform          = string
    splunk_hec_url         = optional(string, "")
    splunk_hec_token       = optional(string, "")
    sentinel_workspace_id  = optional(string, "")
    sentinel_shared_key    = optional(string, "")
    jira_base_url          = string
    jira_project_key       = string
    jira_api_token         = string
    servicenow_url         = optional(string, "")
    servicenow_api_key     = optional(string, "")
  })
  sensitive = true
}

#------------------------------------------------------------------------------
# Notifications Configuration
#------------------------------------------------------------------------------
variable "notifications" {
  description = "Notification configuration"
  type = object({
    slack_webhook_url       = optional(string, "")
    teams_webhook_url       = optional(string, "")
    pagerduty_routing_key   = optional(string, "")
    alert_email_recipients  = string
    email_enabled           = bool
    slack_enabled           = bool
    teams_enabled           = bool
    pagerduty_enabled       = bool
  })
  sensitive = true
}

#------------------------------------------------------------------------------
# Monitoring Configuration
#------------------------------------------------------------------------------
variable "monitoring" {
  description = "Monitoring configuration"
  type = object({
    audit_log_retention_days  = number
    metrics_enabled           = bool
    security_overview_enabled = bool
    alerts_enabled            = bool
    dashboard_enabled         = bool
    log_level                 = string
    health_check_interval     = number
  })
}

#------------------------------------------------------------------------------
# Compliance Configuration
#------------------------------------------------------------------------------
variable "compliance" {
  description = "Compliance framework configuration"
  type = object({
    frameworks       = string
    soc2_enabled     = bool
    pci_dss_enabled  = bool
    hipaa_enabled    = bool
    gdpr_enabled     = bool
    report_frequency = string
  })
}

#------------------------------------------------------------------------------
# DR Configuration
#------------------------------------------------------------------------------
variable "dr" {
  description = "Disaster recovery configuration"
  type = object({
    enabled             = bool
    organization_name   = optional(string, "")
    replication_enabled = bool
    failover_priority   = number
  })
}

#------------------------------------------------------------------------------
# Repository Configuration (Complex Types)
#------------------------------------------------------------------------------
variable "repositories" {
  description = "Map of repositories to configure with security features"
  type = map(object({
    advanced_security_enabled               = bool
    secret_scanning_enabled                 = bool
    secret_scanning_push_protection_enabled = bool
    dependabot_security_updates_enabled     = bool
    branch_protection_enabled               = bool
    protected_branch                        = string
    strict_status_checks                    = bool
    required_status_contexts                = list(string)
    dismiss_stale_reviews                   = bool
    require_code_owner_reviews              = bool
    required_approving_review_count         = number
    dismissal_users                         = list(string)
    dismissal_teams                         = list(string)
    restriction_users                       = list(string)
    restriction_teams                       = list(string)
    restriction_apps                        = list(string)
    enforce_admins                          = bool
    require_signed_commits                  = bool
    require_conversation_resolution         = bool
    codeql_config_enabled                   = bool
    codeql_config_content                   = string
    dependabot_config_enabled               = bool
    dependabot_config_content               = string
    security_policy_enabled                 = bool
    security_policy_content                 = string
  }))
  default = {}
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

variable "repository_security_properties" {
  description = "Repository security property assignments"
  type = map(object({
    repository    = string
    property_name = string
    value         = string
  }))
  default = {}
}

#------------------------------------------------------------------------------
# GitHub Actions Configuration
#------------------------------------------------------------------------------
variable "github_actions_secrets" {
  description = "Organization-level GitHub Actions secrets"
  type = map(object({
    visibility              = string
    plaintext_value         = string
    selected_repository_ids = optional(list(number))
  }))
  default   = {}
  sensitive = true
}

#------------------------------------------------------------------------------
# IP Allowlist Configuration
#------------------------------------------------------------------------------
variable "ip_allowlist" {
  description = "IP addresses allowed to access the organization"
  type = map(object({
    name    = string
    cidr    = string
    enabled = bool
  }))
  default = {}
}
