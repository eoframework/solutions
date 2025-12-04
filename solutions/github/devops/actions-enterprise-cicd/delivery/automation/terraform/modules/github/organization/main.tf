#------------------------------------------------------------------------------
# GitHub Organization Configuration Module
#------------------------------------------------------------------------------
# Configures organization-level settings for GitHub Actions including:
# - Actions permissions (allowed actions, patterns)
# - Runner groups
# - Organization secrets and variables
#------------------------------------------------------------------------------

terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

#===============================================================================
# Organization Actions Permissions
#===============================================================================
resource "github_actions_organization_permissions" "main" {
  allowed_actions      = var.allowed_actions
  enabled_repositories = var.enabled_repositories

  dynamic "allowed_actions_config" {
    for_each = var.allowed_actions == "selected" ? [1] : []
    content {
      github_owned_allowed = var.github_owned_allowed
      verified_allowed     = var.verified_allowed
      patterns_allowed     = var.patterns_allowed
    }
  }
}

#===============================================================================
# Organization Runner Groups
#===============================================================================
resource "github_actions_runner_group" "groups" {
  for_each = var.runner_groups

  name                    = each.value.name
  visibility              = each.value.visibility
  selected_repository_ids = each.value.visibility == "selected" ? each.value.repository_ids : null
  allows_public_repositories = each.value.allows_public_repositories
}

#===============================================================================
# Organization Secrets
#===============================================================================
resource "github_actions_organization_secret" "secrets" {
  for_each = var.organization_secrets

  secret_name     = each.key
  visibility      = each.value.visibility
  plaintext_value = each.value.value

  selected_repository_ids = each.value.visibility == "selected" ? each.value.repository_ids : null
}

#===============================================================================
# Organization Variables
#===============================================================================
resource "github_actions_organization_variable" "variables" {
  for_each = var.organization_variables

  variable_name = each.key
  visibility    = "all"
  value         = each.value
}
