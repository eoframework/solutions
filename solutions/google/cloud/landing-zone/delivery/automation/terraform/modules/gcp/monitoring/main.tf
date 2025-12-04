#------------------------------------------------------------------------------
# GCP Cloud Monitoring Module
#------------------------------------------------------------------------------
# Creates centralized monitoring infrastructure:
# - Notification channels
# - Alert policies
# - Uptime checks
# - Dashboards
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Notification Channels
#------------------------------------------------------------------------------
resource "google_monitoring_notification_channel" "email" {
  count = var.notification_email != "" ? 1 : 0

  project      = var.project_id
  display_name = "${var.name_prefix}-email-channel"
  type         = "email"

  labels = {
    email_address = var.notification_email
  }
}

#------------------------------------------------------------------------------
# Alert Policies
#------------------------------------------------------------------------------
resource "google_monitoring_alert_policy" "cpu_utilization" {
  count = var.monitoring.alert_policy_count > 0 ? 1 : 0

  project      = var.project_id
  display_name = "${var.name_prefix}-high-cpu-utilization"
  combiner     = "OR"

  conditions {
    display_name = "CPU utilization > 80%"

    condition_threshold {
      filter          = "resource.type = \"gce_instance\" AND metric.type = \"compute.googleapis.com/instance/cpu/utilization\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0.8

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }

  notification_channels = var.notification_email != "" ? [google_monitoring_notification_channel.email[0].id] : []

  documentation {
    content   = "CPU utilization has exceeded 80% for 5 minutes."
    mime_type = "text/markdown"
  }

  user_labels = var.common_labels
}

resource "google_monitoring_alert_policy" "memory_utilization" {
  count = var.monitoring.alert_policy_count > 1 ? 1 : 0

  project      = var.project_id
  display_name = "${var.name_prefix}-high-memory-utilization"
  combiner     = "OR"

  conditions {
    display_name = "Memory utilization > 85%"

    condition_threshold {
      filter          = "resource.type = \"gce_instance\" AND metric.type = \"agent.googleapis.com/memory/percent_used\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = 85

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }

  notification_channels = var.notification_email != "" ? [google_monitoring_notification_channel.email[0].id] : []

  documentation {
    content   = "Memory utilization has exceeded 85% for 5 minutes."
    mime_type = "text/markdown"
  }

  user_labels = var.common_labels
}

#------------------------------------------------------------------------------
# Dashboards
#------------------------------------------------------------------------------
resource "google_monitoring_dashboard" "landing_zone" {
  count = var.monitoring.dashboard_count > 0 ? 1 : 0

  project        = var.project_id
  dashboard_json = jsonencode({
    displayName = "${var.name_prefix} Landing Zone Overview"
    gridLayout = {
      columns = 2
      widgets = [
        {
          title = "CPU Utilization"
          xyChart = {
            dataSets = [{
              timeSeriesQuery = {
                timeSeriesFilter = {
                  filter = "resource.type = \"gce_instance\" AND metric.type = \"compute.googleapis.com/instance/cpu/utilization\""
                  aggregation = {
                    alignmentPeriod  = "60s"
                    perSeriesAligner = "ALIGN_MEAN"
                  }
                }
              }
            }]
          }
        },
        {
          title = "Network Traffic"
          xyChart = {
            dataSets = [{
              timeSeriesQuery = {
                timeSeriesFilter = {
                  filter = "resource.type = \"gce_instance\" AND metric.type = \"compute.googleapis.com/instance/network/received_bytes_count\""
                  aggregation = {
                    alignmentPeriod  = "60s"
                    perSeriesAligner = "ALIGN_RATE"
                  }
                }
              }
            }]
          }
        }
      ]
    }
  })
}
