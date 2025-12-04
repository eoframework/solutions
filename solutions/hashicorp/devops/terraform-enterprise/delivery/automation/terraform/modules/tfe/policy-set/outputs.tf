#------------------------------------------------------------------------------
# TFE Policy Set Module Outputs
#------------------------------------------------------------------------------

output "policy_set_ids" {
  description = "Map of policy set names to IDs"
  value       = { for k, v in tfe_policy_set.policy_set : k => v.id }
}

output "policy_set_names" {
  description = "List of policy set names"
  value       = [for k, v in tfe_policy_set.policy_set : v.name]
}

output "enforcement_level" {
  description = "Sentinel enforcement level"
  value       = var.sentinel.enforcement_level
}
