#------------------------------------------------------------------------------
# Azure Virtual Desktop - Production Environment
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
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.45"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }

  subscription_id = var.azure.subscription_id
  tenant_id       = var.azure.tenant_id
}

provider "azuread" {
  tenant_id = var.azure.tenant_id
}

# DR region provider (for cross-region resources)
provider "azurerm" {
  alias = "dr"
  features {}

  subscription_id = var.azure.subscription_id
  tenant_id       = var.azure.tenant_id
}
