#------------------------------------------------------------------------------
# GCP Cloud Monitoring Module - Outputs
#------------------------------------------------------------------------------

output "email_notification_channel_id" {
  description = "Email notification channel ID"
  value       = length(google_monitoring_notification_channel.email) > 0 ? google_monitoring_notification_channel.email[0].id : null
}

output "alert_policy_ids" {
  description = "List of alert policy IDs"
  value = compact([
    length(google_monitoring_alert_policy.cpu_utilization) > 0 ? google_monitoring_alert_policy.cpu_utilization[0].id : null,
    length(google_monitoring_alert_policy.memory_utilization) > 0 ? google_monitoring_alert_policy.memory_utilization[0].id : null,
  ])
}

output "dashboard_ids" {
  description = "List of dashboard IDs"
  value = compact([
    length(google_monitoring_dashboard.landing_zone) > 0 ? google_monitoring_dashboard.landing_zone[0].id : null,
  ])
}
