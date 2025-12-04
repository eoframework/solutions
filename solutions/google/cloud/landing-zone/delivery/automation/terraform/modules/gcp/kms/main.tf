#------------------------------------------------------------------------------
# GCP Cloud KMS Module
#------------------------------------------------------------------------------
# Creates KMS key rings and crypto keys for encryption at rest
# Keys are dynamically created based on key_purposes variable
#------------------------------------------------------------------------------

locals {
  # Default key purposes if not specified
  default_key_purposes = ["primary", "storage", "compute", "database", "secrets", "backup"]

  # Use configured key_count to limit keys created
  key_purposes = slice(
    length(var.key_purposes) > 0 ? var.key_purposes : local.default_key_purposes,
    0,
    min(var.kms.key_count, length(var.key_purposes) > 0 ? length(var.key_purposes) : length(local.default_key_purposes))
  )
}

#------------------------------------------------------------------------------
# KMS Key Ring
#------------------------------------------------------------------------------
resource "google_kms_key_ring" "main" {
  name     = var.kms.keyring_name
  project  = var.project_id
  location = var.kms.keyring_location
}

#------------------------------------------------------------------------------
# KMS Crypto Keys (Dynamic based on key_count)
#------------------------------------------------------------------------------
resource "google_kms_crypto_key" "keys" {
  for_each = toset(local.key_purposes)

  name            = "${var.name_prefix}-${each.key}-key"
  key_ring        = google_kms_key_ring.main.id
  rotation_period = "${var.kms.key_rotation_days * 24 * 60 * 60}s"
  purpose         = "ENCRYPT_DECRYPT"

  version_template {
    algorithm        = var.kms.key_algorithm
    protection_level = var.kms.protection_level
  }

  labels = var.common_labels

  lifecycle {
    prevent_destroy = true
  }
}

#------------------------------------------------------------------------------
# IAM Bindings for Key Usage
#------------------------------------------------------------------------------
resource "google_kms_crypto_key_iam_binding" "encrypter_decrypter" {
  for_each = var.encrypter_decrypter_members

  crypto_key_id = google_kms_crypto_key.keys["primary"].id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  members       = each.value
}
