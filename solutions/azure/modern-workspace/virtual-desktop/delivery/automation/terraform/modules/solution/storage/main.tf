#------------------------------------------------------------------------------
# Storage Module
# Creates: Storage Account, File Share for FSLogix Profiles
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Storage Account for FSLogix Profiles
#------------------------------------------------------------------------------
resource "azurerm_storage_account" "fslogix" {
  name                     = "${replace(var.name_prefix, "-", "")}fslogix"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.storage.account_tier
  account_replication_type = var.storage.account_replication_type
  account_kind             = "FileStorage"
  enable_https_traffic_only = true
  min_tls_version          = "TLS1_2"
  large_file_share_enabled = var.storage.enable_large_file_shares

  azure_files_authentication {
    directory_type = "AADDS"
  }

  network_rules {
    default_action             = var.subnet_id != null ? "Deny" : "Allow"
    bypass                     = ["AzureServices"]
    virtual_network_subnet_ids = var.subnet_id != null ? [var.subnet_id] : []
  }

  tags = var.common_tags
}

#------------------------------------------------------------------------------
# File Share for FSLogix Profiles
#------------------------------------------------------------------------------
resource "azurerm_storage_share" "fslogix" {
  name                 = "fslogix-profiles"
  storage_account_name = azurerm_storage_account.fslogix.name
  quota                = var.storage.share_quota_gb
  enabled_protocol     = "SMB"

  metadata = {
    environment = "production"
    purpose     = "FSLogix User Profiles"
  }
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
    private_connection_resource_id = azurerm_storage_account.fslogix.id
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
  value        = azurerm_storage_account.fslogix.primary_access_key
  key_vault_id = var.key_vault_id
}

resource "azurerm_key_vault_secret" "storage_connection_string" {
  name         = "fslogix-storage-connection-string"
  value        = azurerm_storage_account.fslogix.primary_connection_string
  key_vault_id = var.key_vault_id
}
