#------------------------------------------------------------------------------
# Disaster Recovery Module
# Creates: DR Storage Account, Geo-Replication Configuration
#------------------------------------------------------------------------------

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80"
      configuration_aliases = [azurerm, azurerm.dr]
    }
  }
}

#------------------------------------------------------------------------------
# DR Resource Group
#------------------------------------------------------------------------------
resource "azurerm_resource_group" "dr" {
  provider = azurerm.dr
  name     = "${var.name_prefix}-dr-rg"
  location = var.dr_location
  tags     = merge(var.common_tags, { Purpose = "DisasterRecovery" })
}

#------------------------------------------------------------------------------
# DR Storage Account
#------------------------------------------------------------------------------
resource "random_string" "dr_suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "azurerm_storage_account" "dr" {
  provider                 = azurerm.dr
  name                     = "${replace(var.name_prefix, "-", "")}drst${random_string.dr_suffix.result}"
  resource_group_name      = azurerm_resource_group.dr.name
  location                 = var.dr_location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"

  blob_properties {
    versioning_enabled = true
  }

  tags = merge(var.common_tags, { Purpose = "DisasterRecovery" })
}

#------------------------------------------------------------------------------
# Storage Blob Replication (Object Replication)
#------------------------------------------------------------------------------
resource "azurerm_storage_object_replication" "main" {
  count                        = var.dr.replication_enabled ? 1 : 0
  source_storage_account_id    = var.source_storage_account_id
  destination_storage_account_id = azurerm_storage_account.dr.id

  rules {
    source_container_name      = "input-documents"
    destination_container_name = "input-documents"
  }

  rules {
    source_container_name      = "processed-documents"
    destination_container_name = "processed-documents"
  }
}

#------------------------------------------------------------------------------
# DR Blob Containers
#------------------------------------------------------------------------------
resource "azurerm_storage_container" "dr_input" {
  provider              = azurerm.dr
  name                  = "input-documents"
  storage_account_name  = azurerm_storage_account.dr.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "dr_processed" {
  provider              = azurerm.dr
  name                  = "processed-documents"
  storage_account_name  = azurerm_storage_account.dr.name
  container_access_type = "private"
}
