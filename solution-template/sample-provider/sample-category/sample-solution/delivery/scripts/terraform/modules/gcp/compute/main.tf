# gcp Compute Module
# Compute resources and configuration for gcp

terraform {
  required_providers {
    google = { source = "hashicorp/google", version = "~> 4.0" }
  }
}

# Local values
locals {
  compute_tags = merge(var.tags, {
    Module = "gcp-compute"
  })
}

# TODO: Implement gcp compute resources
# This is a placeholder module - expand with actual resources as needed

