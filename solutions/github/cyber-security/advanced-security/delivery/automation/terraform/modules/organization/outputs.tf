#------------------------------------------------------------------------------
# GitHub Organization Module Outputs
#------------------------------------------------------------------------------

output "organization_id" {
  description = "GitHub organization ID"
  value       = github_organization_settings.org.id
}

output "organization_name" {
  description = "GitHub organization name"
  value       = var.organization_name
}

output "security_manager_teams" {
  description = "Security manager team slugs"
  value       = { for k, v in github_team.security_managers : k => v.slug }
}

output "webhooks" {
  description = "Organization webhook URLs"
  value       = { for k, v in github_organization_webhook.security_events : k => v.url }
  sensitive   = true
}

output "rulesets" {
  description = "Organization ruleset IDs"
  value       = { for k, v in github_organization_ruleset.default_protection : k => v.id }
}
