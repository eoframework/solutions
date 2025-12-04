#------------------------------------------------------------------------------
# Compute Module - Outputs
#------------------------------------------------------------------------------

output "app_service_plan_id" {
  description = "App Service Plan ID"
  value       = module.app_service.service_plan_id
}

output "app_service_plan_name" {
  description = "App Service Plan name"
  value       = module.app_service.service_plan_name
}

output "app_service_id" {
  description = "App Service ID"
  value       = module.app_service.app_service_id
}

output "app_service_name" {
  description = "App Service name"
  value       = module.app_service.app_service_name
}

output "app_service_url" {
  description = "App Service URL"
  value       = module.app_service.app_service_url
}

output "app_service_identity_principal_id" {
  description = "App Service system-assigned identity principal ID"
  value       = module.app_service.app_service_identity_principal_id
}

output "staging_slot_url" {
  description = "Staging slot URL"
  value       = var.app_service_config.deployment_slots_enabled ? "https://${module.app_service.deployment_slot_hostnames["staging"]}" : null
}
