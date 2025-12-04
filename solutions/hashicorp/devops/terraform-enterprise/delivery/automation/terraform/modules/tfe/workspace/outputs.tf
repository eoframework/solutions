#------------------------------------------------------------------------------
# TFE Workspace Module Outputs
#------------------------------------------------------------------------------

output "workspace_ids" {
  description = "Map of workspace names to IDs"
  value       = { for k, v in tfe_workspace.workspace : k => v.id }
}

output "workspace_names" {
  description = "List of workspace names"
  value       = [for k, v in tfe_workspace.workspace : v.name]
}

output "workspace_count" {
  description = "Number of workspaces created"
  value       = length(tfe_workspace.workspace)
}

output "github_oauth_token_id" {
  description = "GitHub OAuth token ID for VCS integration"
  value       = var.integration.github_vcs_enabled ? tfe_oauth_client.github[0].oauth_token_id : null
}
