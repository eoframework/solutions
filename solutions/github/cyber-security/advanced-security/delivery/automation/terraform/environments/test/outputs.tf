#------------------------------------------------------------------------------
# GitHub Advanced Security - Production Environment Outputs
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
output "organization_id" {
  description = "GitHub organization ID"
  value       = module.organization.organization_id
}

output "organization_name" {
  description = "GitHub organization name"
  value       = var.github.organization_name
}

output "organization_settings" {
  description = "Organization security settings status"
  value = {
    advanced_security_enabled = var.codeql.enabled
    secret_scanning_enabled   = var.secret_scanning.enabled
    push_protection_enabled   = var.secret_scanning.push_protection_enabled
    dependabot_enabled        = var.dependabot.enabled
  }
}

#------------------------------------------------------------------------------
# Security Configuration Outputs
#------------------------------------------------------------------------------
output "codeql_configuration" {
  description = "CodeQL analysis configuration"
  value = {
    languages       = var.codeql.languages
    query_suites    = var.codeql.query_suites
    schedule        = var.codeql.schedule
    timeout_minutes = var.codeql.timeout_minutes
  }
}

output "branch_protection_status" {
  description = "Branch protection configuration status"
  value = {
    enabled                 = var.branch_protection.enabled
    required_reviews        = var.branch_protection.required_reviews
    codeql_check_required   = var.branch_protection.require_codeql_pass
    codeowner_review        = var.branch_protection.require_codeowner_review
    linear_history_required = var.branch_protection.require_linear_history
  }
}

output "vulnerability_sla" {
  description = "Vulnerability remediation SLAs (hours)"
  value = {
    critical = var.sla.critical_hours
    high     = var.sla.high_hours
    medium   = var.sla.medium_hours
    low      = var.sla.low_hours
  }
}

#------------------------------------------------------------------------------
# Security Teams
#------------------------------------------------------------------------------
output "security_manager_teams" {
  description = "Security manager team slugs"
  value       = module.organization.security_manager_teams
}

#------------------------------------------------------------------------------
# Repository Outputs
#------------------------------------------------------------------------------
output "repositories_with_advanced_security" {
  description = "Repositories with Advanced Security enabled"
  value       = module.repository_security.repositories_with_advanced_security
}

output "repositories_with_secret_scanning" {
  description = "Repositories with secret scanning enabled"
  value       = module.repository_security.repositories_with_secret_scanning
}

output "repositories_with_push_protection" {
  description = "Repositories with push protection enabled"
  value       = module.repository_security.repositories_with_push_protection
}

output "repositories_with_dependabot" {
  description = "Repositories with Dependabot enabled"
  value       = module.repository_security.repositories_with_dependabot
}

output "protected_repositories" {
  description = "Repositories with branch protection"
  value       = module.repository_security.protected_repositories
}

#------------------------------------------------------------------------------
# Actions Configuration
#------------------------------------------------------------------------------
output "actions_allowed_actions" {
  description = "Actions permissions configuration"
  value       = module.actions.allowed_actions
}

#------------------------------------------------------------------------------
# Security Properties
#------------------------------------------------------------------------------
output "security_custom_properties" {
  description = "Organization custom property names"
  value       = module.security.custom_properties
}

#------------------------------------------------------------------------------
# Integration Outputs
#------------------------------------------------------------------------------
output "siem_integration" {
  description = "SIEM integration status"
  value = {
    platform        = var.integration.siem_platform
    webhook_enabled = var.integration.siem_webhook_url != ""
    event_types     = var.integration.siem_event_types
  }
}

output "notification_channels" {
  description = "Notification channel status"
  value = {
    email_enabled     = var.notifications.email_enabled
    slack_enabled     = var.notifications.slack_enabled
    teams_enabled     = var.notifications.teams_enabled
    pagerduty_enabled = var.notifications.pagerduty_enabled
  }
}

#------------------------------------------------------------------------------
# Compliance Outputs
#------------------------------------------------------------------------------
output "compliance_status" {
  description = "Compliance framework enablement status"
  value = {
    frameworks       = var.compliance.frameworks
    soc2_enabled     = var.compliance.soc2_enabled
    pci_dss_enabled  = var.compliance.pci_dss_enabled
    hipaa_enabled    = var.compliance.hipaa_enabled
    gdpr_enabled     = var.compliance.gdpr_enabled
    report_frequency = var.compliance.report_frequency
  }
}

#------------------------------------------------------------------------------
# DR Outputs
#------------------------------------------------------------------------------
output "dr_status" {
  description = "Disaster recovery configuration status"
  value = {
    enabled             = var.dr.enabled
    replication_enabled = var.dr.replication_enabled
    failover_priority   = var.dr.failover_priority
  }
}
