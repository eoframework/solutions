#------------------------------------------------------------------------------
# GitHub Advanced Security - DR Environment
#------------------------------------------------------------------------------
# Disaster Recovery configuration for GHAS organization failover
# Maintains configuration parity with production
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
    Purpose      = "Disaster Recovery"
    Standby      = "true"
  }

  # CodeQL configuration (mirrors production)
  codeql_config_content = templatefile("${path.module}/../../config/codeql-config.yml.tpl", {
    languages           = var.codeql.languages
    query_suites        = var.codeql.query_suites
    custom_queries_repo = var.codeql.custom_queries_repo
  })

  # Dependabot configuration
  dependabot_config_content = templatefile("${path.module}/../../config/dependabot.yml.tpl", {
    package_ecosystems = var.dependabot.package_ecosystems
    schedule           = var.dependabot.schedule
  })

  # Security policy content
  security_policy_content = file("${path.module}/../../config/SECURITY.md")
}

#------------------------------------------------------------------------------
# Provider Configuration
#------------------------------------------------------------------------------
provider "github" {
  owner = var.github.organization_name
  token = var.auth.api_token
}

#===============================================================================
# FOUNDATION - Organization Configuration (DR - Production Parity)
#===============================================================================
module "organization" {
  source = "../../modules/organization"

  organization_name = var.github.organization_name
  billing_email     = var.ownership.owner_email
  company_name      = var.solution.name
  email             = var.ownership.owner_email
  description       = "GitHub Advanced Security - Disaster Recovery organization"

  # Production-equivalent permissions
  default_repository_permission           = "read"
  members_can_create_repositories         = false
  members_can_create_public_repositories  = false
  members_can_create_private_repositories = false
  web_commit_signoff_required             = true

  # Security settings (match production)
  advanced_security_enabled               = var.codeql.enabled
  dependabot_alerts_enabled               = var.dependabot.enabled
  dependabot_security_updates_enabled     = var.dependabot.security_updates
  dependency_graph_enabled                = true
  secret_scanning_enabled                 = var.secret_scanning.enabled
  secret_scanning_push_protection_enabled = var.secret_scanning.push_protection_enabled

  # Security manager teams (same as production)
  security_manager_teams = {
    security_team = {
      name        = "Security Team DR"
      description = "Security team with security manager permissions (DR)"
      privacy     = "closed"
    }
  }

  # Webhooks for SIEM integration (DR endpoints)
  webhooks = var.integration.siem_webhook_url != "" ? {
    siem_integration = {
      active       = true
      events       = ["code_scanning_alert", "secret_scanning_alert", "dependabot_alert", "security_advisory"]
      url          = var.integration.siem_webhook_url
      content_type = "json"
      insecure_ssl = false
      secret       = var.integration.siem_webhook_secret
    }
  } : {}

  # Organization-wide rulesets (production parity)
  rulesets = {
    default_branch_protection = {
      name                              = "DR Branch Protection"
      target                            = "branch"
      enforcement                       = "active"
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
      require_last_push_approval        = true
      required_review_thread_resolution = true
      required_status_checks            = var.branch_protection.require_codeql_pass
      strict_required_status_checks     = true
      require_signed_commits            = false
      require_linear_history            = var.branch_protection.require_linear_history
      allow_force_pushes                = var.branch_protection.allow_force_pushes
      allow_deletions                   = var.branch_protection.allow_deletions
    }
  }
}

#===============================================================================
# CORE SOLUTION - Repository Security Configuration (DR)
#===============================================================================
module "repository_security" {
  source = "../../modules/repository"

  repositories = var.repositories

  commit_author = "GHAS DR Automation"
  commit_email  = "ghas-dr@${var.github.organization_name}.github.com"

  repository_environments = var.repository_environments
}

#===============================================================================
# OPERATIONS - GitHub Actions and Security Controls (DR)
#===============================================================================
module "actions" {
  source = "../../modules/actions"

  allowed_actions      = "selected"
  enabled_repositories = "all"

  github_owned_allowed = true
  verified_allowed     = true
  patterns_allowed = [
    "github/*",
    "actions/*",
    "docker/*",
  ]

  organization_secrets = var.github_actions_secrets

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
    DR_STANDBY = {
      visibility = "all"
      value      = "true"
    }
  }
}

#------------------------------------------------------------------------------
# Security Configuration (DR - Production Parity)
#------------------------------------------------------------------------------
module "security" {
  source = "../../modules/security"

  custom_properties = {
    security_tier = {
      property_name  = "security_tier"
      value_type     = "single_select"
      description    = "Security tier classification"
      required       = true
      default_value  = "standard"
      allowed_values = ["critical", "high", "standard", "low"]
    }
    compliance_framework = {
      property_name  = "compliance_framework"
      value_type     = "multi_select"
      description    = "Applicable compliance frameworks"
      required       = false
      default_value  = null
      allowed_values = ["SOC2", "PCI-DSS", "HIPAA", "GDPR"]
    }
    data_classification = {
      property_name  = "data_classification"
      value_type     = "single_select"
      description    = "Data classification level"
      required       = true
      default_value  = "internal"
      allowed_values = ["public", "internal", "confidential", "restricted"]
    }
  }

  repository_properties = var.repository_security_properties
  ip_allowlist          = var.ip_allowlist
}
