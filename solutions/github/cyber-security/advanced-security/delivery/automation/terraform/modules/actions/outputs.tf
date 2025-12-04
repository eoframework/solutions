#------------------------------------------------------------------------------
# GitHub Actions Module Outputs
#------------------------------------------------------------------------------

output "allowed_actions" {
  description = "Allowed actions configuration"
  value       = var.allowed_actions
}

output "organization_secrets" {
  description = "Organization secret names"
  value       = keys(github_actions_organization_secret.org_secrets)
}

output "organization_variables" {
  description = "Organization variable names"
  value       = keys(github_actions_organization_variable.org_variables)
}

output "runner_groups" {
  description = "Runner group IDs"
  value       = { for k, v in github_actions_runner_group.runner_groups : k => v.id }
}
