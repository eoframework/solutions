# GitHub Repository Configuration Module
# Configures repository-level settings for GitHub Actions

terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
  }
}

#===============================================================================
# Repository Configuration
#===============================================================================
resource "github_repository" "repo" {
  count = var.create_repository ? 1 : 0

  name        = var.repository_name
  description = var.description
  visibility  = var.visibility

  has_issues      = var.has_issues
  has_wiki        = var.has_wiki
  has_projects    = var.has_projects
  has_discussions = var.has_discussions

  allow_merge_commit     = var.allow_merge_commit
  allow_squash_merge     = var.allow_squash_merge
  allow_rebase_merge     = var.allow_rebase_merge
  allow_auto_merge       = var.allow_auto_merge
  delete_branch_on_merge = var.delete_branch_on_merge

  vulnerability_alerts = var.vulnerability_alerts
  archived             = var.archived

  topics = var.topics
}

#===============================================================================
# Branch Protection
#===============================================================================
resource "github_branch_protection" "main" {
  count = var.enable_branch_protection ? 1 : 0

  repository_id = var.create_repository ? github_repository.repo[0].node_id : var.repository_id
  pattern       = var.protected_branch_pattern

  required_status_checks {
    strict   = var.require_up_to_date_branch
    contexts = var.required_status_checks
  }

  required_pull_request_reviews {
    dismiss_stale_reviews           = var.dismiss_stale_reviews
    require_code_owner_reviews      = var.require_code_owner_reviews
    required_approving_review_count = var.required_approving_review_count
    restrict_dismissals             = var.restrict_review_dismissals
  }

  enforce_admins                  = var.enforce_admins
  require_signed_commits          = var.require_signed_commits
  require_linear_history          = var.require_linear_history
  require_conversation_resolution = var.require_conversation_resolution
  allows_deletions                = var.allows_deletions
  allows_force_pushes             = var.allows_force_pushes
}

#===============================================================================
# Repository Environments
#===============================================================================
resource "github_repository_environment" "environments" {
  for_each = var.environments

  repository  = var.create_repository ? github_repository.repo[0].name : var.repository_name
  environment = each.key

  dynamic "reviewers" {
    for_each = each.value.reviewers != null ? [1] : []
    content {
      teams = each.value.reviewers.teams
      users = each.value.reviewers.users
    }
  }

  dynamic "deployment_branch_policy" {
    for_each = each.value.deployment_branch_policy != null ? [1] : []
    content {
      protected_branches     = each.value.deployment_branch_policy.protected_branches
      custom_branch_policies = each.value.deployment_branch_policy.custom_branch_policies
    }
  }

  wait_timer = each.value.wait_timer
}

#===============================================================================
# Repository Secrets
#===============================================================================
resource "github_actions_secret" "secrets" {
  for_each = var.repository_secrets

  repository      = var.create_repository ? github_repository.repo[0].name : var.repository_name
  secret_name     = each.key
  plaintext_value = each.value
}

#===============================================================================
# Repository Variables
#===============================================================================
resource "github_actions_variable" "variables" {
  for_each = var.repository_variables

  repository    = var.create_repository ? github_repository.repo[0].name : var.repository_name
  variable_name = each.key
  value         = each.value
}

#===============================================================================
# Environment Secrets
#===============================================================================
resource "github_actions_environment_secret" "env_secrets" {
  for_each = local.env_secrets_flat

  repository      = var.create_repository ? github_repository.repo[0].name : var.repository_name
  environment     = each.value.environment
  secret_name     = each.value.secret_name
  plaintext_value = each.value.value
}

#===============================================================================
# Environment Variables
#===============================================================================
resource "github_actions_environment_variable" "env_variables" {
  for_each = local.env_variables_flat

  repository    = var.create_repository ? github_repository.repo[0].name : var.repository_name
  environment   = each.value.environment
  variable_name = each.value.variable_name
  value         = each.value.value
}

locals {
  # Flatten environment secrets
  env_secrets_flat = merge([
    for env_name, env_config in var.environments : {
      for secret_name, secret_value in coalesce(env_config.secrets, {}) :
      "${env_name}_${secret_name}" => {
        environment = env_name
        secret_name = secret_name
        value       = secret_value
      }
    }
  ]...)

  # Flatten environment variables
  env_variables_flat = merge([
    for env_name, env_config in var.environments : {
      for var_name, var_value in coalesce(env_config.variables, {}) :
      "${env_name}_${var_name}" => {
        environment   = env_name
        variable_name = var_name
        value         = var_value
      }
    }
  ]...)
}
