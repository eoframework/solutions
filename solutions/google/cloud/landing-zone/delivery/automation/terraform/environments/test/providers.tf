#------------------------------------------------------------------------------
# GCP Landing Zone Production Providers
#------------------------------------------------------------------------------

terraform {
  required_version = ">= 1.6.0"

  backend "gcs" {
    # Values loaded from backend.tfvars via -backend-config flag
    # Run setup/backend/state-backend.sh to create backend resources
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 5.0"
    }
  }
}

provider "google" {
  project = var.gcp.project_id
  region  = var.gcp.region

  default_labels = local.common_labels
}

provider "google-beta" {
  project = var.gcp.project_id
  region  = var.gcp.region

  default_labels = local.common_labels
}

# DR region provider
provider "google" {
  alias   = "dr"
  project = var.gcp.project_id
  region  = var.gcp.dr_region

  default_labels = local.common_labels
}
