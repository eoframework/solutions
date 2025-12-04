#------------------------------------------------------------------------------
# Azure Storage Account Module
#------------------------------------------------------------------------------
# Creates Storage Accounts with:
# - File shares for FSLogix profiles
# - Network rules and private endpoints
# - Azure Files authentication
# - Replication configuration
#------------------------------------------------------------------------------

resource "azurerm_storage_account" "this" {
  name                            = var.name
  resource_group_name             = var.resource_group_name
  location                        = var.location
  account_tier                    = var.account_tier
  account_replication_type        = var.replication_type
  account_kind                    = var.account_kind
  access_tier                     = var.access_tier
  min_tls_version                 = var.min_tls_version
  https_traffic_only_enabled      = true
  allow_nested_items_to_be_public = var.allow_public_access
  shared_access_key_enabled       = var.shared_access_key_enabled
  public_network_access_enabled   = var.public_network_access_enabled
  large_file_share_enabled        = var.large_file_share_enabled

  # Azure Files authentication
  dynamic "azure_files_authentication" {
    for_each = var.azure_files_authentication != null ? [var.azure_files_authentication] : []
    content {
      directory_type = azure_files_authentication.value.directory_type

      dynamic "active_directory" {
        for_each = lookup(azure_files_authentication.value, "active_directory", null) != null ? [azure_files_authentication.value.active_directory] : []
        content {
          domain_guid         = active_directory.value.domain_guid
          domain_name         = active_directory.value.domain_name
          domain_sid          = active_directory.value.domain_sid
          forest_name         = active_directory.value.forest_name
          netbios_domain_name = active_directory.value.netbios_domain_name
          storage_sid         = active_directory.value.storage_sid
        }
      }
    }
  }

  # Network rules
  dynamic "network_rules" {
    for_each = var.enable_network_rules ? [1] : []
    content {
      default_action             = var.network_default_action
      bypass                     = var.network_bypass
      ip_rules                   = var.allowed_ip_ranges
      virtual_network_subnet_ids = var.allowed_subnet_ids
    }
  }

  # Identity for CMK
  dynamic "identity" {
    for_each = var.identity_type != null ? [1] : []
    content {
      type         = var.identity_type
      identity_ids = var.identity_ids
    }
  }

  tags = var.common_tags
}

#------------------------------------------------------------------------------
# File Shares
#------------------------------------------------------------------------------
resource "azurerm_storage_share" "this" {
  for_each = var.file_shares

  name                 = each.key
  storage_account_name = azurerm_storage_account.this.name
  quota                = each.value.quota_gb
  enabled_protocol     = lookup(each.value, "protocol", "SMB")
  access_tier          = lookup(each.value, "access_tier", null)

  metadata = lookup(each.value, "metadata", {})
}

#------------------------------------------------------------------------------
# Blob Containers
#------------------------------------------------------------------------------
resource "azurerm_storage_container" "this" {
  for_each = var.containers

  name                  = each.key
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = lookup(each.value, "access_type", "private")
}
