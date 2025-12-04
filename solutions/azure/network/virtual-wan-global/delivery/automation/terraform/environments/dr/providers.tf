#------------------------------------------------------------------------------
# Azure Virtual WAN Global - Production Environment
# Terraform and Provider Configuration
#------------------------------------------------------------------------------

terraform {
  required_version = ">= 1.6.0"

  backend "azurerm" {
    # Values loaded from backend.tfvars via -backend-config flag
    # Run setup/backend/state-backend.sh to create backend resources
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }

  subscription_id = var.azure.subscription_id
  tenant_id       = var.azure.tenant_id
}
