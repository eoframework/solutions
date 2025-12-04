# GitHub Repository Module Outputs

output "repository_id" {
  description = "Repository ID"
  value       = var.create_repository ? github_repository.repo[0].repo_id : null
}

output "repository_name" {
  description = "Repository name"
  value       = var.repository_name
}

output "repository_full_name" {
  description = "Repository full name"
  value       = var.create_repository ? github_repository.repo[0].full_name : null
}

output "repository_html_url" {
  description = "Repository HTML URL"
  value       = var.create_repository ? github_repository.repo[0].html_url : null
}

output "environments" {
  description = "Configured environments"
  value       = keys(github_repository_environment.environments)
}
