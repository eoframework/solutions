#------------------------------------------------------------------------------
# Sentinel Policy Set Module Outputs
#------------------------------------------------------------------------------

output "policy_set_id" {
  description = "Policy set ID"
  value       = tfe_policy_set.main.id
}

output "policy_set_name" {
  description = "Policy set name"
  value       = tfe_policy_set.main.name
}

output "cost_policy_id" {
  description = "Cost estimation policy ID"
  value       = var.sentinel.enable_cost_policies ? tfe_policy.cost_estimation[0].id : ""
}

output "tag_policy_id" {
  description = "Mandatory tags policy ID"
  value       = var.sentinel.enable_tag_policies ? tfe_policy.mandatory_tags[0].id : ""
}

output "provider_policy_id" {
  description = "Allowed providers policy ID"
  value       = var.sentinel.enable_provider_policies ? tfe_policy.allowed_providers[0].id : ""
}
