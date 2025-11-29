# Google Cloud Provider-Specific Module
# This module contains all GCP-specific resources and configurations

# Local values for GCP resource naming
locals {
  gcp_name_prefix = "${var.name_prefix}-gcp"

  # Common labels for all GCP resources (must be lowercase with underscores)
  gcp_labels = {
    for k, v in merge(var.labels, {
      provider = "gcp"
      region   = replace(var.region, "-", "_")
    }) :
    lower(replace(k, " ", "_")) => lower(replace(v, " ", "_"))
  }
}

# GCP Networking Module
module "networking" {
  source = "./networking"

  name_prefix = local.gcp_name_prefix
  tags        = local.gcp_labels
}

# GCP Security Module
module "security" {
  source = "./security"

  name_prefix = local.gcp_name_prefix
  tags        = local.gcp_labels
}

# GCP Compute Module
module "compute" {
  source = "./compute"

  name_prefix = local.gcp_name_prefix
  tags        = local.gcp_labels
}

# GCP Monitoring Module
module "monitoring" {
  source = "./monitoring"

  project_name        = var.project_name
  environment         = var.environment
  name_prefix         = local.gcp_name_prefix
  project_id          = var.project_id
  region              = var.region
  labels              = local.gcp_labels
  log_retention_days  = var.log_retention_days
}

# Example GCP-specific resources
resource "google_storage_bucket" "app_bucket" {
  name          = "${local.gcp_name_prefix}-app-bucket-${random_id.bucket_suffix.hex}"
  location      = var.region
  force_destroy = true

  uniform_bucket_level_access = true

  labels = merge(local.gcp_labels, {
    name = replace("${local.gcp_name_prefix}-app-bucket", "-", "_")
  })
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}