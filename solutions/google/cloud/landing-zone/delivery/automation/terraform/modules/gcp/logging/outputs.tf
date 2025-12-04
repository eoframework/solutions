#------------------------------------------------------------------------------
# GCP Cloud Logging Module - Outputs
#------------------------------------------------------------------------------

output "sink_name" {
  description = "Name of the organization log sink"
  value       = google_logging_organization_sink.aggregated.name
}

output "sink_writer_identity" {
  description = "Writer identity of the log sink"
  value       = google_logging_organization_sink.aggregated.writer_identity
}

output "bigquery_dataset_id" {
  description = "BigQuery dataset ID for logs"
  value       = var.logging.sink_type == "BigQuery" ? google_bigquery_dataset.logs[0].dataset_id : null
}

output "storage_bucket_name" {
  description = "Cloud Storage bucket name for logs"
  value       = var.logging.sink_type == "Cloud Storage" ? google_storage_bucket.logs[0].name : null
}

output "security_events_metric" {
  description = "Name of the security events log-based metric"
  value       = var.enable_metrics ? google_logging_metric.security_events[0].name : null
}

output "error_count_metric" {
  description = "Name of the error count log-based metric"
  value       = var.enable_metrics ? google_logging_metric.error_count[0].name : null
}
