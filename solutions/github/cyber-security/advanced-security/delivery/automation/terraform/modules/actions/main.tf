#------------------------------------------------------------------------------
# GitHub Actions Configuration Module
#------------------------------------------------------------------------------
# Configures GitHub Actions settings including:
# - Organization Actions permissions
# - Allowed actions and reusable workflows
# - Runner groups
# - Organization secrets
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
# Organization Actions Permissions
#------------------------------------------------------------------------------
resource "github_actions_organization_permissions" "org_actions" {
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

  dynamic "enabled_repositories_config" {
    for_each = var.enabled_repositories == "selected" ? [1] : []
    content {
      repository_ids = var.enabled_repository_ids
    }
  }
}

#------------------------------------------------------------------------------
# Organization Secrets
#------------------------------------------------------------------------------
resource "github_actions_organization_secret" "org_secrets" {
  for_each = var.organization_secrets

  secret_name     = each.key
  visibility      = each.value.visibility
  plaintext_value = each.value.plaintext_value

  dynamic "selected_repository_ids" {
    for_each = each.value.visibility == "selected" ? [1] : []
    content {
      selected_repository_ids = each.value.selected_repository_ids
    }
  }
}

#------------------------------------------------------------------------------
# Organization Variables
#------------------------------------------------------------------------------
resource "github_actions_organization_variable" "org_variables" {
  for_each = var.organization_variables

  variable_name = each.key
  visibility    = each.value.visibility
  value         = each.value.value

  dynamic "selected_repository_ids" {
    for_each = each.value.visibility == "selected" ? [1] : []
    content {
      selected_repository_ids = each.value.selected_repository_ids
    }
  }
}

#------------------------------------------------------------------------------
# Runner Groups (Enterprise only)
#------------------------------------------------------------------------------
resource "github_actions_runner_group" "runner_groups" {
  for_each = var.runner_groups

  name                    = each.value.name
  visibility              = each.value.visibility
  selected_repository_ids = each.value.selected_repository_ids
  allows_public_repositories = each.value.allows_public_repositories
  restricted_to_workflows    = each.value.restricted_to_workflows
  selected_workflows         = each.value.selected_workflows
}
