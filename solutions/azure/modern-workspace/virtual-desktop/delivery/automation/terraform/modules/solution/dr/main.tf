#------------------------------------------------------------------------------
# Disaster Recovery Module
# Creates: DR Storage Account, Cross-Region Replication
#------------------------------------------------------------------------------

terraform {
  required_providers {
    azurerm = {
      source                = "hashicorp/azurerm"
      version               = "~> 3.80"
      configuration_aliases = [azurerm.dr]
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
  tags     = var.common_tags
}

#------------------------------------------------------------------------------
# DR Storage Account for FSLogix Profiles
#------------------------------------------------------------------------------
resource "azurerm_storage_account" "dr" {
  provider                 = azurerm.dr
  count                    = var.dr.replication_enabled ? 1 : 0
  name                     = "${replace(var.name_prefix, "-", "")}drfslogix"
  resource_group_name      = azurerm_resource_group.dr.name
  location                 = var.dr_location
  account_tier             = "Standard"
  account_replication_type = "GRS"
  account_kind             = "FileStorage"

  tags = merge(var.common_tags, {
    Purpose = "Disaster Recovery"
  })
}

#------------------------------------------------------------------------------
# DR File Share
#------------------------------------------------------------------------------
resource "azurerm_storage_share" "dr" {
  provider             = azurerm.dr
  count                = var.dr.replication_enabled ? 1 : 0
  name                 = "fslogix-profiles-dr"
  storage_account_name = azurerm_storage_account.dr[0].name
  quota                = 5120

  metadata = {
    environment = "disaster-recovery"
    purpose     = "FSLogix User Profiles DR"
  }
}
