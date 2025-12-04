#------------------------------------------------------------------------------
# GitHub Advanced Security - Test Environment
#------------------------------------------------------------------------------
# Simplified test configuration with relaxed security policies for development
#------------------------------------------------------------------------------

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }

  backend "local" {
    path = "terraform.tfstate"
  }
}

#------------------------------------------------------------------------------
# Locals
#------------------------------------------------------------------------------
locals {
  environment = basename(path.module)
  name_prefix = "${var.solution.abbr}-${local.environment}"

  # Environment display name mapping
  env_display_name = {
    prod = "Production"
    test = "Test"
    dr   = "Disaster Recovery"
  }

  #----------------------------------------------------------------------------
  # Shared Configuration Objects
  #----------------------------------------------------------------------------
  project = {
    name        = var.solution.abbr
    environment = local.environment
  }

  common_tags = {
    Solution     = var.solution.name
    SolutionAbbr = var.solution.abbr
    Environment  = local.environment
    Provider     = var.solution.provider_name
    Category     = var.solution.category_name
    ManagedBy    = "terraform"
    CostCenter   = var.ownership.cost_center
    Owner        = var.ownership.owner_email
    ProjectCode  = var.ownership.project_code
  }
}

#------------------------------------------------------------------------------
# Provider Configuration
#------------------------------------------------------------------------------
provider "github" {
  owner = var.github.organization_name
  token = var.auth.api_token
}

#===============================================================================
# FOUNDATION - Organization Configuration (Test - Relaxed Policies)
#===============================================================================
module "organization" {
  source = "../../modules/organization"

  organization_name = var.github.organization_name
  billing_email     = var.ownership.owner_email
  company_name      = var.solution.name
  email             = var.ownership.owner_email
  description       = "GitHub Advanced Security test organization"

  # More permissive for testing
  default_repository_permission           = "write"
  members_can_create_repositories         = true
  members_can_create_private_repositories = true
  web_commit_signoff_required             = false

  # Security settings (enabled but relaxed)
  advanced_security_enabled               = var.codeql.enabled
  dependabot_alerts_enabled               = var.dependabot.enabled
  dependabot_security_updates_enabled     = var.dependabot.security_updates
  dependency_graph_enabled                = true
  secret_scanning_enabled                 = var.secret_scanning.enabled
  secret_scanning_push_protection_enabled = var.secret_scanning.push_protection_enabled

  security_manager_teams = {}
  webhooks               = {}

  # Relaxed rulesets for test
  rulesets = var.branch_protection.enabled ? {
    default_branch_protection = {
      name                              = "Test Branch Protection"
      target                            = "branch"
      enforcement                       = "evaluate"  # Evaluate only, don't enforce
      ref_name_include                  = ["~DEFAULT_BRANCH"]
      ref_name_exclude                  = []
      repository_name_include           = ["*"]
      repository_name_exclude           = []
      bypass_actor_id                   = 0
      bypass_actor_type                 = "Integration"
      bypass_mode                       = "always"
      require_pull_request              = var.branch_protection.enabled
      required_approving_review_count   = var.branch_protection.required_reviews
      dismiss_stale_reviews             = var.branch_protection.dismiss_stale_reviews
      require_code_owner_review         = var.branch_protection.require_codeowner_review
      require_last_push_approval        = false
      required_review_thread_resolution = false
      required_status_checks            = false  # Not required in test
      strict_required_status_checks     = false
      require_signed_commits            = false
      require_linear_history            = var.branch_protection.require_linear_history
      allow_force_pushes                = true  # Allow in test
      allow_deletions                   = true  # Allow in test
    }
  } : {}
}

#===============================================================================
# CORE SOLUTION - Repository Security Configuration (Test)
#===============================================================================
module "repository_security" {
  source = "../../modules/repository"

  repositories = var.repositories

  commit_author = "GHAS Test Automation"
  commit_email  = "ghas-test@${var.github.organization_name}.github.com"

  repository_environments = {}
}

#===============================================================================
# OPERATIONS - GitHub Actions (Test - Open Configuration)
#===============================================================================
module "actions" {
  source = "../../modules/actions"

  allowed_actions      = "all"  # Allow all actions in test
  enabled_repositories = "all"

  github_owned_allowed = true
  verified_allowed     = true
  patterns_allowed     = []

  organization_secrets = {}

  organization_variables = {
    CODEQL_LANGUAGES = {
      visibility = "all"
      value      = var.codeql.languages
    }
    SECURITY_ENABLED = {
      visibility = "all"
      value      = "true"
    }
    ENVIRONMENT = {
      visibility = "all"
      value      = local.environment
    }
  }
}

#------------------------------------------------------------------------------
# Security Configuration (Test - Minimal)
#------------------------------------------------------------------------------
module "security" {
  source = "../../modules/security"

  custom_properties     = {}
  repository_properties = {}
  ip_allowlist          = {}
}
