#------------------------------------------------------------------------------
# GCP Cloud Logging Module
#------------------------------------------------------------------------------
# Creates centralized logging infrastructure:
# - Log sinks for organization-wide aggregation
# - BigQuery dataset for log analytics
# - Cloud Storage bucket for long-term retention
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Log Sink Destination - BigQuery Dataset
#------------------------------------------------------------------------------
resource "google_bigquery_dataset" "logs" {
  count = var.logging.sink_type == "BigQuery" ? 1 : 0

  dataset_id                 = "${replace(var.name_prefix, "-", "_")}_logs"
  project                    = var.project_id
  location                   = var.location
  delete_contents_on_destroy = false

  default_partition_expiration_ms = var.logging.bigquery_retention_years * 365 * 24 * 60 * 60 * 1000
  default_table_expiration_ms     = var.logging.bigquery_retention_years * 365 * 24 * 60 * 60 * 1000

  labels = var.common_labels
}

#------------------------------------------------------------------------------
# Log Sink Destination - Cloud Storage Bucket
#------------------------------------------------------------------------------
resource "google_storage_bucket" "logs" {
  count = var.logging.sink_type == "Cloud Storage" ? 1 : 0

  name          = "${var.name_prefix}-logs-${var.project_id}"
  project       = var.project_id
  location      = var.location
  storage_class = "STANDARD"

  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  lifecycle_rule {
    condition {
      age = var.logging.retention_days
    }
    action {
      type          = "SetStorageClass"
      storage_class = "NEARLINE"
    }
  }

  lifecycle_rule {
    condition {
      age = var.logging.retention_days * 2
    }
    action {
      type          = "SetStorageClass"
      storage_class = "COLDLINE"
    }
  }

  lifecycle_rule {
    condition {
      age = var.logging.retention_days * 4
    }
    action {
      type          = "SetStorageClass"
      storage_class = "ARCHIVE"
    }
  }

  versioning {
    enabled = true
  }

  labels = var.common_labels
}

#------------------------------------------------------------------------------
# Organization Log Sink - Aggregated Logs
#------------------------------------------------------------------------------
resource "google_logging_organization_sink" "aggregated" {
  name             = "${var.name_prefix}-org-sink"
  org_id           = var.org_id
  include_children = true

  destination = var.logging.sink_type == "BigQuery" ? (
    "bigquery.googleapis.com/${google_bigquery_dataset.logs[0].id}"
  ) : (
    "storage.googleapis.com/${google_storage_bucket.logs[0].name}"
  )

  filter = var.log_filter

  # BigQuery-specific options
  dynamic "bigquery_options" {
    for_each = var.logging.sink_type == "BigQuery" ? [1] : []
    content {
      use_partitioned_tables = true
    }
  }
}

#------------------------------------------------------------------------------
# Grant permissions to the sink's service account
#------------------------------------------------------------------------------
resource "google_bigquery_dataset_iam_member" "log_writer" {
  count = var.logging.sink_type == "BigQuery" ? 1 : 0

  dataset_id = google_bigquery_dataset.logs[0].dataset_id
  project    = var.project_id
  role       = "roles/bigquery.dataEditor"
  member     = google_logging_organization_sink.aggregated.writer_identity
}

resource "google_storage_bucket_iam_member" "log_writer" {
  count = var.logging.sink_type == "Cloud Storage" ? 1 : 0

  bucket = google_storage_bucket.logs[0].name
  role   = "roles/storage.objectCreator"
  member = google_logging_organization_sink.aggregated.writer_identity
}

#------------------------------------------------------------------------------
# Audit Logs Configuration
#------------------------------------------------------------------------------
resource "google_organization_iam_audit_config" "all_services" {
  count = var.logging.enable_audit_logs ? 1 : 0

  org_id  = var.org_id
  service = "allServices"

  audit_log_config {
    log_type = "ADMIN_READ"
  }

  audit_log_config {
    log_type = "DATA_READ"
  }

  audit_log_config {
    log_type = "DATA_WRITE"
  }
}

#------------------------------------------------------------------------------
# Log-Based Metrics for Monitoring (conditional on enable_metrics)
#------------------------------------------------------------------------------
resource "google_logging_metric" "security_events" {
  count = var.enable_metrics ? 1 : 0

  name    = "${var.name_prefix}-security-events"
  project = var.project_id

  filter = var.security_events_filter

  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
    unit        = "1"
    labels {
      key         = "method"
      value_type  = "STRING"
      description = "The IAM method that was called"
    }
  }

  label_extractors = {
    "method" = "EXTRACT(protoPayload.methodName)"
  }
}

resource "google_logging_metric" "error_count" {
  count = var.enable_metrics ? 1 : 0

  name    = "${var.name_prefix}-error-count"
  project = var.project_id

  filter = var.error_filter

  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
    unit        = "1"
    labels {
      key         = "resource_type"
      value_type  = "STRING"
      description = "The type of resource that generated the error"
    }
  }

  label_extractors = {
    "resource_type" = "EXTRACT(resource.type)"
  }
}
