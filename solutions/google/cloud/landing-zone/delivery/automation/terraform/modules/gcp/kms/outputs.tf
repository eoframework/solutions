#------------------------------------------------------------------------------
# GCP Cloud KMS Module Outputs
#------------------------------------------------------------------------------

output "key_ring_id" {
  description = "KMS key ring ID"
  value       = google_kms_key_ring.main.id
}

output "keyring_id" {
  description = "KMS key ring ID (alias)"
  value       = google_kms_key_ring.main.id
}

output "key_ring_name" {
  description = "KMS key ring name"
  value       = google_kms_key_ring.main.name
}

output "primary_key_id" {
  description = "Primary crypto key ID"
  value       = contains(local.key_purposes, "primary") ? google_kms_crypto_key.keys["primary"].id : null
}

output "primary_key_name" {
  description = "Primary crypto key name"
  value       = contains(local.key_purposes, "primary") ? google_kms_crypto_key.keys["primary"].name : null
}

output "key_ids" {
  description = "Map of all crypto key IDs"
  value       = { for k, v in google_kms_crypto_key.keys : k => v.id }
}

output "key_names" {
  description = "Map of all crypto key names"
  value       = { for k, v in google_kms_crypto_key.keys : k => v.name }
}

output "key_count" {
  description = "Number of keys created"
  value       = length(google_kms_crypto_key.keys)
}
