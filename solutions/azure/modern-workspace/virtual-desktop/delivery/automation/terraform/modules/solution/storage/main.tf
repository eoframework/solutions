#------------------------------------------------------------------------------
# Storage Module
# Creates: Storage Account, File Share for FSLogix Profiles
# Uses: modules/azure/storage-account
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Storage Account for FSLogix Profiles (via Azure module)
#------------------------------------------------------------------------------
module "storage_account" {
  source = "../../azure/storage-account"

  name                = "${replace(var.name_prefix, "-", "")}fslogix"
  resource_group_name = var.resource_group_name
  location            = var.location
  account_tier        = var.storage.account_tier
  replication_type    = var.storage.account_replication_type
  account_kind        = "FileStorage"

  large_file_share_enabled = var.storage.enable_large_file_shares

  azure_files_authentication = {
    directory_type = "AADDS"
  }

  enable_network_rules   = var.subnet_id != null
  network_default_action = var.subnet_id != null ? "Deny" : "Allow"
  network_bypass         = ["AzureServices"]
  allowed_subnet_ids     = var.subnet_id != null ? [var.subnet_id] : []

  file_shares = {
    "fslogix-profiles" = {
      quota_gb = var.storage.share_quota_gb
      protocol = "SMB"
      metadata = {
        environment = "production"
        purpose     = "FSLogix User Profiles"
      }
    }
  }

  common_tags = var.common_tags
}

#------------------------------------------------------------------------------
# Private Endpoint for Storage Account (if enabled)
#------------------------------------------------------------------------------
resource "azurerm_private_endpoint" "fslogix" {
  count               = var.subnet_id != null ? 1 : 0
  name                = "${var.name_prefix}-fslogix-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "${var.name_prefix}-fslogix-psc"
    private_connection_resource_id = module.storage_account.id
    is_manual_connection           = false
    subresource_names              = ["file"]
  }

  tags = var.common_tags
}

#------------------------------------------------------------------------------
# Store Storage Account Key in Key Vault
#------------------------------------------------------------------------------
resource "azurerm_key_vault_secret" "storage_key" {
  name         = "fslogix-storage-account-key"
  value        = module.storage_account.primary_access_key
  key_vault_id = var.key_vault_id
}

resource "azurerm_key_vault_secret" "storage_connection_string" {
  name         = "fslogix-storage-connection-string"
  value        = module.storage_account.primary_connection_string
  key_vault_id = var.key_vault_id
}
