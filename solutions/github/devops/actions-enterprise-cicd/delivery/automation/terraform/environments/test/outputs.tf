#------------------------------------------------------------------------------
# GitHub Actions Enterprise CI/CD - Production Environment Outputs
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Environment Information
#------------------------------------------------------------------------------
output "environment" {
  description = "Environment name"
  value       = local.environment
}

output "solution_info" {
  description = "Solution metadata"
  value = {
    name        = var.solution.name
    abbr        = var.solution.abbr
    version     = var.solution.version
    environment = local.environment
    provider    = var.solution.provider_name
    category    = var.solution.category_name
  }
}

#------------------------------------------------------------------------------
# Organization Outputs
#------------------------------------------------------------------------------
output "organization_name" {
  description = "GitHub organization name"
  value       = var.github.organization_name
}

output "organization_settings" {
  description = "Organization Actions settings"
  value = {
    allowed_actions      = "selected"
    github_owned_allowed = true
    verified_allowed     = true
    actions_minutes      = var.github.actions_minutes
  }
}

output "runner_groups" {
  description = "Configured runner groups"
  value       = module.organization.runner_group_ids
}

output "organization_secrets_configured" {
  description = "Organization secrets configured"
  value       = module.organization.organization_secrets
}

output "organization_variables_configured" {
  description = "Organization variables configured"
  value       = module.organization.organization_variables
}

#------------------------------------------------------------------------------
# Runner Configuration Outputs
#------------------------------------------------------------------------------
output "runner_capacity" {
  description = "Runner capacity configuration"
  value = {
    linux = {
      instance_type = var.runners.instance_type_linux
      min           = var.runners.asg_min_linux
      max           = var.runners.asg_max_linux
      desired       = var.runners.count_linux
    }
    windows = {
      instance_type = var.runners.instance_type_windows
      min           = var.runners.asg_min_windows
      max           = var.runners.asg_max_windows
      desired       = var.runners.count_windows
    }
  }
}

#------------------------------------------------------------------------------
# Repository Outputs
#------------------------------------------------------------------------------
output "github_repository_name" {
  description = "GitHub repository name"
  value       = module.github_repo.repository_name
}

output "github_repository_url" {
  description = "GitHub repository URL"
  value       = module.github_repo.repository_html_url
}

output "environments_configured" {
  description = "Repository environments configured"
  value       = module.github_repo.environments
}

#------------------------------------------------------------------------------
# Container Registries
#------------------------------------------------------------------------------
output "container_registries" {
  description = "Container registry URLs"
  value = {
    ecr  = var.container.ecr_registry_url
    ghcr = var.container.ghcr_registry_url
  }
}

#------------------------------------------------------------------------------
# Workflow Configuration Outputs
#------------------------------------------------------------------------------
output "workflow_configuration" {
  description = "Workflow defaults"
  value = {
    template_repo      = var.workflows.template_repo
    build_timeout      = var.workflows.build_timeout
    artifact_retention = var.workflows.artifact_retention
    cache_key_prefix   = var.workflows.cache_key_prefix
  }
}

#------------------------------------------------------------------------------
# Security Outputs
#------------------------------------------------------------------------------
output "security_features_enabled" {
  description = "Security features status"
  value = {
    advanced_security  = module.security.advanced_security_enabled
    secret_scanning    = module.security.secret_scanning_enabled
    oidc_customization = module.security.oidc_customization_enabled
  }
}

#------------------------------------------------------------------------------
# Governance Outputs
#------------------------------------------------------------------------------
output "governance_status" {
  description = "Governance configuration"
  value = {
    branch_protection_enabled = var.governance.branch_protection_enabled
    required_reviewers        = var.governance.environment_reviewers_count
    wait_timer_minutes        = var.governance.environment_wait_timer
  }
}

#------------------------------------------------------------------------------
# Performance Targets
#------------------------------------------------------------------------------
output "performance_targets" {
  description = "Performance SLOs"
  value = {
    pipeline_duration_seconds = var.performance.pipeline_target_duration
    deployment_success_rate   = var.performance.deployment_success_target
  }
}

#------------------------------------------------------------------------------
# DR Configuration
#------------------------------------------------------------------------------
output "dr_status" {
  description = "Disaster recovery configuration"
  value = {
    enabled           = var.dr.enabled
    failover_priority = var.dr.failover_priority
  }
}
