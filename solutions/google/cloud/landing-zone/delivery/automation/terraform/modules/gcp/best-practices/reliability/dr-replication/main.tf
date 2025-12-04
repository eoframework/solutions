#------------------------------------------------------------------------------
# GCP DR Replication Module
#------------------------------------------------------------------------------
# Creates cross-region replication infrastructure for disaster recovery
# Well-Architected Framework: Reliability
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Cross-Region Replication Bucket
#------------------------------------------------------------------------------
resource "google_storage_bucket" "dr_replication" {
  count = var.dr.enabled && var.dr.cross_region_replication ? 1 : 0

  name          = "${var.name_prefix}-dr-replication-${var.project_id}"
  project       = var.project_id
  location      = var.dr_region
  storage_class = "STANDARD"

  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition {
      age = var.dr.archive_after_days
    }
    action {
      type          = "SetStorageClass"
      storage_class = "NEARLINE"
    }
  }

  lifecycle_rule {
    condition {
      age = var.dr.coldline_after_days
    }
    action {
      type          = "SetStorageClass"
      storage_class = "COLDLINE"
    }
  }

  labels = merge(var.common_labels, {
    purpose = "dr-replication"
  })
}

#------------------------------------------------------------------------------
# DR Failover Health Check
#------------------------------------------------------------------------------
resource "google_compute_health_check" "failover" {
  count = var.dr.enabled && var.dr.enable_health_check ? 1 : 0

  name    = "${var.name_prefix}-failover-health"
  project = var.project_id

  check_interval_sec  = var.dr.health_check_interval_sec
  timeout_sec         = var.dr.health_check_timeout_sec
  healthy_threshold   = var.dr.healthy_threshold
  unhealthy_threshold = var.dr.unhealthy_threshold

  http_health_check {
    port         = var.dr.health_check_port
    request_path = var.dr.health_check_path
  }
}

#------------------------------------------------------------------------------
# DR KMS Key (for cross-region encryption)
#------------------------------------------------------------------------------
resource "google_kms_key_ring" "dr" {
  count = var.dr.enabled && var.dr.enable_dr_kms ? 1 : 0

  name     = "${var.name_prefix}-dr-keyring"
  project  = var.project_id
  location = var.dr_region
}

resource "google_kms_crypto_key" "dr" {
  count = var.dr.enabled && var.dr.enable_dr_kms ? 1 : 0

  name            = "${var.name_prefix}-dr-key"
  key_ring        = google_kms_key_ring.dr[0].id
  rotation_period = "${var.dr.key_rotation_days * 24 * 60 * 60}s"

  lifecycle {
    prevent_destroy = false  # Allow destruction for non-prod
  }
}
