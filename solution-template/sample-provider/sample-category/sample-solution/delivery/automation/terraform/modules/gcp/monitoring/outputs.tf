# GCP Monitoring Module - Outputs

output "log_sinks" {
  description = "Cloud Logging sinks created"
  value = {
    application_logs = google_logging_project_sink.application_logs.id
    system_logs      = google_logging_project_sink.system_logs.id
  }
}

output "logs_bucket" {
  description = "Cloud Storage bucket for logs"
  value = {
    name = google_storage_bucket.logs.name
    url  = google_storage_bucket.logs.url
  }
}

output "notification_channels" {
  description = "Monitoring notification channels"
  value = [
    for channel in google_monitoring_notification_channel.email : {
      id   = channel.id
      name = channel.display_name
    }
  ]
}

output "alert_policies" {
  description = "Monitoring alert policies created"
  value = {
    high_cpu    = google_monitoring_alert_policy.high_cpu.id
    high_memory = google_monitoring_alert_policy.high_memory.id
  }
}

output "dashboard_url" {
  description = "Cloud Monitoring dashboard URL"
  value       = "https://console.cloud.google.com/monitoring/dashboards/custom/${google_monitoring_dashboard.main.id}?project=${var.project_id}"
}

output "audit_logs_config" {
  description = "Audit logs configuration"
  value       = google_project_iam_audit_config.audit_logs.id
}