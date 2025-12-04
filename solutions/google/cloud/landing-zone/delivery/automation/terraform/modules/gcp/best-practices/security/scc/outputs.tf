#------------------------------------------------------------------------------
# GCP Security Command Center Module - Outputs
#------------------------------------------------------------------------------

output "critical_findings_module_id" {
  description = "SCC critical findings custom module ID"
  value       = length(google_scc_organization_custom_module.critical_findings) > 0 ? google_scc_organization_custom_module.critical_findings[0].id : null
}

output "public_resources_module_id" {
  description = "SCC public resources custom module ID"
  value       = length(google_scc_organization_custom_module.public_resources) > 0 ? google_scc_organization_custom_module.public_resources[0].id : null
}

output "notification_config_id" {
  description = "SCC notification config ID"
  value       = length(google_scc_notification_config.findings) > 0 ? google_scc_notification_config.findings[0].id : null
}
