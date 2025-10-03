# gcp Security Module
# Security resources and configuration for gcp

terraform {
  required_providers {
    google = { source = "hashicorp/google", version = "~> 4.0" }
  }
}

# Local values
locals {
  security_tags = merge(var.tags, {
    Module = "gcp-security"
  })
}

# TODO: Implement gcp security resources
# This is a placeholder module - expand with actual resources as needed

