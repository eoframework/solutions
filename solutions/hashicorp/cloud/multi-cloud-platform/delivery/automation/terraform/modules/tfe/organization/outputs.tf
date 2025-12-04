#------------------------------------------------------------------------------
# TFE Organization Module Outputs
#------------------------------------------------------------------------------

output "organization_name" {
  description = "TFC/TFE organization name"
  value       = tfe_organization.main.name
}

output "organization_id" {
  description = "TFC/TFE organization ID"
  value       = tfe_organization.main.id
}

output "oauth_client_id" {
  description = "GitHub OAuth client ID"
  value       = var.tfc.github_enabled ? tfe_oauth_client.github[0].id : ""
}

output "oauth_token_id" {
  description = "GitHub OAuth token ID"
  value       = var.tfc.github_enabled ? tfe_oauth_client.github[0].oauth_token_id : ""
}

output "agent_pool_id" {
  description = "Agent pool ID"
  value       = var.tfc.enable_agents ? tfe_agent_pool.main[0].id : ""
}

output "agent_token" {
  description = "Agent token (sensitive)"
  value       = var.tfc.enable_agents ? tfe_agent_token.main[0].token : ""
  sensitive   = true
}

output "common_variable_set_id" {
  description = "Common variable set ID"
  value       = tfe_variable_set.common.id
}
