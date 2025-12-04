#------------------------------------------------------------------------------
# GitHub Repository Module Outputs
#------------------------------------------------------------------------------

output "repositories_with_advanced_security" {
  description = "List of repositories with Advanced Security enabled"
  value = [
    for repo, config in var.repositories :
    repo if config.advanced_security_enabled
  ]
}

output "repositories_with_secret_scanning" {
  description = "List of repositories with secret scanning enabled"
  value = [
    for repo, config in var.repositories :
    repo if config.secret_scanning_enabled
  ]
}

output "repositories_with_push_protection" {
  description = "List of repositories with push protection enabled"
  value = [
    for repo, config in var.repositories :
    repo if config.secret_scanning_push_protection_enabled
  ]
}

output "repositories_with_dependabot" {
  description = "List of repositories with Dependabot enabled"
  value = [
    for repo, config in var.repositories :
    repo if config.dependabot_security_updates_enabled
  ]
}

output "protected_repositories" {
  description = "List of repositories with branch protection"
  value = [
    for repo, config in var.repositories :
    repo if config.branch_protection_enabled
  ]
}

output "repository_environments" {
  description = "Repository environment names"
  value = {
    for k, v in github_repository_environment.environments :
    k => v.environment
  }
}
