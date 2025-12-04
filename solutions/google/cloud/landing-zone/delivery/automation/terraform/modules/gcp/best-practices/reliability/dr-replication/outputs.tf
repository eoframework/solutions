#------------------------------------------------------------------------------
# GCP DR Replication Module - Outputs
#------------------------------------------------------------------------------

output "replication_bucket_name" {
  description = "DR replication bucket name"
  value       = length(google_storage_bucket.dr_replication) > 0 ? google_storage_bucket.dr_replication[0].name : null
}

output "replication_bucket_url" {
  description = "DR replication bucket URL"
  value       = length(google_storage_bucket.dr_replication) > 0 ? google_storage_bucket.dr_replication[0].url : null
}

output "health_check_id" {
  description = "Failover health check ID"
  value       = length(google_compute_health_check.failover) > 0 ? google_compute_health_check.failover[0].id : null
}

output "health_check_self_link" {
  description = "Failover health check self link"
  value       = length(google_compute_health_check.failover) > 0 ? google_compute_health_check.failover[0].self_link : null
}

output "dr_kms_key_id" {
  description = "DR KMS crypto key ID"
  value       = length(google_kms_crypto_key.dr) > 0 ? google_kms_crypto_key.dr[0].id : null
}
