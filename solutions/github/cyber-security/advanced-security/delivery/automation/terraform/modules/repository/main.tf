#------------------------------------------------------------------------------
# GitHub Repository Security Configuration Module
#------------------------------------------------------------------------------
# Enables and configures security features for repositories including:
# - Advanced Security features
# - Code scanning (CodeQL)
# - Secret scanning with push protection
# - Dependabot
# - Branch protection rules
#------------------------------------------------------------------------------

terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

#------------------------------------------------------------------------------
# Repository Security and Analysis
#------------------------------------------------------------------------------
resource "github_repository_security_and_analysis" "security" {
  for_each   = var.repositories
  repository = each.key

  security_and_analysis {
    advanced_security {
      status = each.value.advanced_security_enabled ? "enabled" : "disabled"
    }

    secret_scanning {
      status = each.value.secret_scanning_enabled ? "enabled" : "disabled"
    }

    secret_scanning_push_protection {
      status = each.value.secret_scanning_push_protection_enabled ? "enabled" : "disabled"
    }
  }
}

#------------------------------------------------------------------------------
# Repository Vulnerability Alerts
#------------------------------------------------------------------------------
resource "github_repository_dependabot_security_updates" "dependabot" {
  for_each   = { for k, v in var.repositories : k => v if v.dependabot_security_updates_enabled }
  repository = each.key
  enabled    = true
}

#------------------------------------------------------------------------------
# Repository Branch Protection (v4 - Legacy)
#------------------------------------------------------------------------------
resource "github_branch_protection_v3" "protection" {
  for_each   = { for k, v in var.repositories : k => v if v.branch_protection_enabled }
  repository = each.key
  branch     = each.value.protected_branch

  required_status_checks {
    strict   = each.value.strict_status_checks
    contexts = each.value.required_status_contexts
  }

  required_pull_request_reviews {
    dismiss_stale_reviews           = each.value.dismiss_stale_reviews
    require_code_owner_reviews      = each.value.require_code_owner_reviews
    required_approving_review_count = each.value.required_approving_review_count
    dismissal_users                 = each.value.dismissal_users
    dismissal_teams                 = each.value.dismissal_teams
  }

  restrictions {
    users = each.value.restriction_users
    teams = each.value.restriction_teams
    apps  = each.value.restriction_apps
  }

  enforce_admins                  = each.value.enforce_admins
  require_signed_commits          = each.value.require_signed_commits
  require_conversation_resolution = each.value.require_conversation_resolution
}

#------------------------------------------------------------------------------
# CodeQL Analysis Configuration File
#------------------------------------------------------------------------------
resource "github_repository_file" "codeql_config" {
  for_each            = { for k, v in var.repositories : k => v if v.codeql_config_enabled }
  repository          = each.key
  branch              = each.value.protected_branch
  file                = ".github/codeql/codeql-config.yml"
  content             = each.value.codeql_config_content
  commit_message      = "Add CodeQL configuration"
  commit_author       = var.commit_author
  commit_email        = var.commit_email
  overwrite_on_create = true
}

#------------------------------------------------------------------------------
# Dependabot Configuration File
#------------------------------------------------------------------------------
resource "github_repository_file" "dependabot_config" {
  for_each            = { for k, v in var.repositories : k => v if v.dependabot_config_enabled }
  repository          = each.key
  branch              = each.value.protected_branch
  file                = ".github/dependabot.yml"
  content             = each.value.dependabot_config_content
  commit_message      = "Add Dependabot configuration"
  commit_author       = var.commit_author
  commit_email        = var.commit_email
  overwrite_on_create = true
}

#------------------------------------------------------------------------------
# Security Policy File
#------------------------------------------------------------------------------
resource "github_repository_file" "security_policy" {
  for_each            = { for k, v in var.repositories : k => v if v.security_policy_enabled }
  repository          = each.key
  branch              = each.value.protected_branch
  file                = "SECURITY.md"
  content             = each.value.security_policy_content
  commit_message      = "Add security policy"
  commit_author       = var.commit_author
  commit_email        = var.commit_email
  overwrite_on_create = false
}

#------------------------------------------------------------------------------
# Repository Secrets (for Actions)
#------------------------------------------------------------------------------
resource "github_actions_secret" "repository_secrets" {
  for_each = var.repository_secrets

  repository      = each.value.repository
  secret_name     = each.value.secret_name
  plaintext_value = each.value.plaintext_value
}

#------------------------------------------------------------------------------
# Repository Environments
#------------------------------------------------------------------------------
resource "github_repository_environment" "environments" {
  for_each = var.repository_environments

  repository  = each.value.repository
  environment = each.value.environment

  deployment_branch_policy {
    protected_branches     = each.value.protected_branches
    custom_branch_policies = each.value.custom_branch_policies
  }

  reviewers {
    users = each.value.reviewer_users
    teams = each.value.reviewer_teams
  }

  wait_timer = each.value.wait_timer
}
