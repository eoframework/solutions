# GCP Monitoring Module
# Cloud Monitoring, Cloud Logging, and alerting configuration

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

# Local values for GCP monitoring
locals {
  monitoring_name_prefix = "${var.name_prefix}-monitoring"

  # Common labels for monitoring resources
  monitoring_labels = merge(var.labels, {
    module  = "gcp-monitoring"
    purpose = "observability"
  })
}

# Cloud Logging - Log Sink for application logs
resource "google_logging_project_sink" "application_logs" {
  name                   = "${local.monitoring_name_prefix}-app-logs"
  destination            = "storage.googleapis.com/${google_storage_bucket.logs.name}"
  filter                 = "resource.type=\"gce_instance\" AND logName=\"projects/${var.project_id}/logs/application\""
  unique_writer_identity = true
}

# Cloud Logging - Log Sink for system logs
resource "google_logging_project_sink" "system_logs" {
  name                   = "${local.monitoring_name_prefix}-sys-logs"
  destination            = "storage.googleapis.com/${google_storage_bucket.logs.name}"
  filter                 = "resource.type=\"gce_instance\" AND logName=\"projects/${var.project_id}/logs/syslog\""
  unique_writer_identity = true
}

# Cloud Storage bucket for log storage
resource "google_storage_bucket" "logs" {
  name                        = "${local.monitoring_name_prefix}-logs-${random_id.bucket_suffix.hex}"
  location                    = var.region
  force_destroy               = true
  uniform_bucket_level_access = true

  lifecycle_rule {
    condition {
      age = var.log_retention_days
    }
    action {
      type = "Delete"
    }
  }

  labels = local.monitoring_labels
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# IAM binding for log sink to write to bucket
resource "google_storage_bucket_iam_binding" "logs_writer" {
  bucket = google_storage_bucket.logs.name
  role   = "roles/storage.objectCreator"

  members = [
    google_logging_project_sink.application_logs.writer_identity,
    google_logging_project_sink.system_logs.writer_identity,
  ]
}

# Cloud Monitoring - Notification Channel
resource "google_monitoring_notification_channel" "email" {
  count        = length(var.notification_emails)
  display_name = "Email Notification ${count.index + 1}"
  type         = "email"

  labels = {
    email_address = var.notification_emails[count.index]
  }
}

# Cloud Monitoring - Alert Policy for high CPU
resource "google_monitoring_alert_policy" "high_cpu" {
  display_name = "${local.monitoring_name_prefix} High CPU Usage"
  combiner     = "OR"

  conditions {
    display_name = "High CPU condition"

    condition_threshold {
      filter          = "resource.type=\"gce_instance\""
      comparison      = "COMPARISON_GREATER_THAN"
      threshold_value = 0.8
      duration        = "300s"

      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }

  notification_channels = google_monitoring_notification_channel.email[*].id

  alert_strategy {
    auto_close = "1800s" # 30 minutes
  }
}

# Cloud Monitoring - Alert Policy for high memory
resource "google_monitoring_alert_policy" "high_memory" {
  display_name = "${local.monitoring_name_prefix} High Memory Usage"
  combiner     = "OR"

  conditions {
    display_name = "High Memory condition"

    condition_threshold {
      filter          = "resource.type=\"gce_instance\""
      comparison      = "COMPARISON_GREATER_THAN"
      threshold_value = 0.85
      duration        = "300s"

      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }

  notification_channels = google_monitoring_notification_channel.email[*].id

  alert_strategy {
    auto_close = "1800s"
  }
}

# Cloud Monitoring - Dashboard
resource "google_monitoring_dashboard" "main" {
  dashboard_json = jsonencode({
    displayName = "${local.monitoring_name_prefix} Dashboard"

    mosaicLayout = {
      tiles = [
        {
          width  = 6
          height = 4
          widget = {
            title = "CPU Utilization"
            xyChart = {
              dataSets = [
                {
                  timeSeriesQuery = {
                    timeSeriesFilter = {
                      filter = "resource.type=\"gce_instance\""
                      aggregation = {
                        alignmentPeriod  = "300s"
                        perSeriesAligner = "ALIGN_MEAN"
                      }
                    }
                  }
                  plotType = "LINE"
                }
              ]
              timeshiftDuration = "0s"
              yAxis = {
                label = "CPU Usage"
                scale = "LINEAR"
              }
            }
          }
        },
        {
          width  = 6
          height = 4
          xPos   = 6
          widget = {
            title = "Memory Utilization"
            xyChart = {
              dataSets = [
                {
                  timeSeriesQuery = {
                    timeSeriesFilter = {
                      filter = "resource.type=\"gce_instance\""
                      aggregation = {
                        alignmentPeriod  = "300s"
                        perSeriesAligner = "ALIGN_MEAN"
                      }
                    }
                  }
                  plotType = "LINE"
                }
              ]
              timeshiftDuration = "0s"
              yAxis = {
                label = "Memory Usage"
                scale = "LINEAR"
              }
            }
          }
        }
      ]
    }
  })
}

# Cloud Audit Logs configuration
resource "google_project_iam_audit_config" "audit_logs" {
  project = var.project_id

  audit_log_config {
    service = "allServices"
    log_type = "ADMIN_READ"
  }

  audit_log_config {
    service = "allServices"
    log_type = "DATA_READ"
  }

  audit_log_config {
    service = "allServices"
    log_type = "DATA_WRITE"
  }
}