# azure Compute Module
# Compute resources and configuration for azure

terraform {
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 3.0" }
  }
}

# Local values
locals {
  compute_tags = merge(var.tags, {
    Module = "azure-compute"
  })
}

# TODO: Implement azure compute resources
# This is a placeholder module - expand with actual resources as needed

