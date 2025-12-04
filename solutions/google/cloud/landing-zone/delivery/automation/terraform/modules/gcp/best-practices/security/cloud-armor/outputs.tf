#------------------------------------------------------------------------------
# GCP Cloud Armor Module - Outputs
#------------------------------------------------------------------------------

output "policy_id" {
  description = "Cloud Armor security policy ID"
  value       = length(google_compute_security_policy.default) > 0 ? google_compute_security_policy.default[0].id : null
}

output "policy_name" {
  description = "Cloud Armor security policy name"
  value       = length(google_compute_security_policy.default) > 0 ? google_compute_security_policy.default[0].name : null
}

output "policy_self_link" {
  description = "Cloud Armor security policy self link"
  value       = length(google_compute_security_policy.default) > 0 ? google_compute_security_policy.default[0].self_link : null
}
