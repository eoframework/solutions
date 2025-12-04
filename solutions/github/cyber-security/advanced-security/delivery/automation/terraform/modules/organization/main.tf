#------------------------------------------------------------------------------
# GitHub Organization Configuration Module
#------------------------------------------------------------------------------
# Configures organization-level settings for GitHub Advanced Security including:
# - Organization security settings
# - SAML/SSO configuration
# - Advanced Security enablement
# - Security policies
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
# Organization Settings
#------------------------------------------------------------------------------
resource "github_organization_settings" "org" {
  billing_email                                                = var.billing_email
  company                                                      = var.company_name
  blog                                                         = var.blog_url
  email                                                        = var.email
  twitter_username                                             = var.twitter_username
  location                                                     = var.location
  name                                                         = var.organization_name
  description                                                  = var.description
  has_organization_projects                                    = var.has_organization_projects
  has_repository_projects                                      = var.has_repository_projects
  default_repository_permission                                = var.default_repository_permission
  members_can_create_repositories                              = var.members_can_create_repositories
  members_can_create_public_repositories                       = var.members_can_create_public_repositories
  members_can_create_private_repositories                      = var.members_can_create_private_repositories
  members_can_create_internal_repositories                     = var.members_can_create_internal_repositories
  members_can_create_pages                                     = var.members_can_create_pages
  members_can_create_public_pages                              = var.members_can_create_public_pages
  members_can_create_private_pages                             = var.members_can_create_private_pages
  members_can_fork_private_repositories                        = var.members_can_fork_private_repositories
  web_commit_signoff_required                                  = var.web_commit_signoff_required
  advanced_security_enabled_for_new_repositories               = var.advanced_security_enabled
  dependabot_alerts_enabled_for_new_repositories               = var.dependabot_alerts_enabled
  dependabot_security_updates_enabled_for_new_repositories     = var.dependabot_security_updates_enabled
  dependency_graph_enabled_for_new_repositories                = var.dependency_graph_enabled
  secret_scanning_enabled_for_new_repositories                 = var.secret_scanning_enabled
  secret_scanning_push_protection_enabled_for_new_repositories = var.secret_scanning_push_protection_enabled
}

#------------------------------------------------------------------------------
# Organization Security Manager Teams
#------------------------------------------------------------------------------
resource "github_team" "security_managers" {
  for_each = var.security_manager_teams

  name        = each.value.name
  description = each.value.description
  privacy     = each.value.privacy
}

resource "github_organization_security_manager" "security_managers" {
  for_each = github_team.security_managers

  team_slug = each.value.slug
}

#------------------------------------------------------------------------------
# Organization Webhooks
#------------------------------------------------------------------------------
resource "github_organization_webhook" "security_events" {
  for_each = var.webhooks

  active = each.value.active
  events = each.value.events

  configuration {
    url          = each.value.url
    content_type = each.value.content_type
    insecure_ssl = each.value.insecure_ssl
    secret       = each.value.secret
  }
}

#------------------------------------------------------------------------------
# Organization Rulesets (Branch Protection)
#------------------------------------------------------------------------------
resource "github_organization_ruleset" "default_protection" {
  for_each = var.rulesets

  name        = each.value.name
  target      = each.value.target
  enforcement = each.value.enforcement

  conditions {
    ref_name {
      include = each.value.ref_name_include
      exclude = each.value.ref_name_exclude
    }

    repository_name {
      include = each.value.repository_name_include
      exclude = each.value.repository_name_exclude
    }
  }

  bypass_actors {
    actor_id    = each.value.bypass_actor_id
    actor_type  = each.value.bypass_actor_type
    bypass_mode = each.value.bypass_mode
  }

  rules {
    # Require pull request reviews
    dynamic "pull_request" {
      for_each = each.value.require_pull_request ? [1] : []
      content {
        required_approving_review_count   = each.value.required_approving_review_count
        dismiss_stale_reviews_on_push     = each.value.dismiss_stale_reviews
        require_code_owner_review         = each.value.require_code_owner_review
        require_last_push_approval        = each.value.require_last_push_approval
        required_review_thread_resolution = each.value.required_review_thread_resolution
      }
    }

    # Require status checks
    dynamic "required_status_checks" {
      for_each = each.value.required_status_checks != null ? [1] : []
      content {
        required_check {
          context        = "CodeQL"
          integration_id = null
        }
        required_check {
          context        = "Secret Scanning"
          integration_id = null
        }
        strict_required_status_checks_policy = each.value.strict_required_status_checks
      }
    }

    # Require commit signing
    dynamic "required_signatures" {
      for_each = each.value.require_signed_commits ? [1] : []
      content {}
    }

    # Require linear history
    dynamic "required_linear_history" {
      for_each = each.value.require_linear_history ? [1] : []
      content {}
    }

    # Block force pushes
    dynamic "non_fast_forward" {
      for_each = !each.value.allow_force_pushes ? [1] : []
      content {}
    }

    # Block deletions
    dynamic "deletion" {
      for_each = !each.value.allow_deletions ? [1] : []
      content {}
    }
  }
}
