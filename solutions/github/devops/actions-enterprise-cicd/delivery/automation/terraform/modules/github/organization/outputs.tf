# GitHub Organization Module Outputs

output "runner_group_ids" {
  description = "Map of runner group names to IDs"
  value       = { for k, v in github_actions_runner_group.groups : k => v.id }
}

output "organization_secrets" {
  description = "List of organization secrets configured"
  value       = keys(github_actions_organization_secret.secrets)
}

output "organization_variables" {
  description = "List of organization variables configured"
  value       = keys(github_actions_organization_variable.variables)
}
