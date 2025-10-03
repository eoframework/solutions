# azure Security Module
# Security resources and configuration for azure

terraform {
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 3.0" }
  }
}

# Local values
locals {
  security_tags = merge(var.tags, {
    Module = "azure-security"
  })
}

# TODO: Implement azure security resources
# This is a placeholder module - expand with actual resources as needed

