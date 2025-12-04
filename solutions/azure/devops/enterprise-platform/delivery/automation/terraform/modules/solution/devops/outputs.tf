#------------------------------------------------------------------------------
# Azure DevOps Module - Outputs
#------------------------------------------------------------------------------

output "project_id" {
  description = "Azure DevOps project ID"
  value       = azuredevops_project.main.id
}

output "project_name" {
  description = "Azure DevOps project name"
  value       = azuredevops_project.main.name
}

output "project_url" {
  description = "Azure DevOps project URL"
  value       = "${var.devops.organization_url}/${azuredevops_project.main.name}"
}

output "default_repo_id" {
  description = "Default repository ID"
  value       = data.azuredevops_git_repository.default.id
}

output "default_repo_url" {
  description = "Default repository URL"
  value       = data.azuredevops_git_repository.default.remote_url
}

output "service_connection_id" {
  description = "Azure service connection ID"
  value       = var.service_connections.azure_rm_enabled ? azuredevops_serviceendpoint_azurerm.main[0].id : null
}

output "ci_pipeline_id" {
  description = "CI pipeline ID"
  value       = var.pipelines.enable_ci ? azuredevops_build_definition.ci[0].id : null
}
