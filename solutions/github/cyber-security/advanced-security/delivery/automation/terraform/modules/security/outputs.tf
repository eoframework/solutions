#------------------------------------------------------------------------------
# GitHub Security Module Outputs
#------------------------------------------------------------------------------

output "custom_properties" {
  description = "Organization custom property names"
  value       = keys(github_organization_custom_properties.security_properties)
}

output "repository_properties" {
  description = "Repository custom property assignments"
  value       = { for k, v in github_repository_custom_property.repo_properties : k => v.value }
}

output "ip_allowlist" {
  description = "IP allowlist entries"
  value       = { for k, v in github_organization_ip_allowlist.allowed_ips : k => v.cidr }
}
