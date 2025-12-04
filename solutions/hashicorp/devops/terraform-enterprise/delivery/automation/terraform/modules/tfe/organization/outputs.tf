#------------------------------------------------------------------------------
# TFE Organization Module Outputs
#------------------------------------------------------------------------------

output "organization_name" {
  description = "TFE organization name"
  value       = tfe_organization.org.name
}

output "organization_id" {
  description = "TFE organization ID"
  value       = tfe_organization.org.id
}

output "admin_token" {
  description = "Organization admin API token"
  value       = tfe_organization_token.admin.token
  sensitive   = true
}
