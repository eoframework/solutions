#------------------------------------------------------------------------------
# Azure Document Intelligence (Form Recognizer) Module
#------------------------------------------------------------------------------
# Creates Cognitive Services account for document processing with:
# - Custom models support
# - Network rules and private endpoints
# - Customer-managed encryption
# - Managed identity
#------------------------------------------------------------------------------

resource "azurerm_cognitive_account" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  kind                = "FormRecognizer"
  sku_name            = var.sku_name

  # Custom subdomain (required for AAD auth and private endpoints)
  custom_subdomain_name = var.custom_subdomain_name

  # Network rules
  public_network_access_enabled = var.public_network_access_enabled

  dynamic "network_acls" {
    for_each = var.enable_network_acls ? [1] : []
    content {
      default_action = var.network_default_action
      ip_rules       = var.allowed_ip_ranges

      dynamic "virtual_network_rules" {
        for_each = var.virtual_network_rules
        content {
          subnet_id                            = virtual_network_rules.value.subnet_id
          ignore_missing_vnet_service_endpoint = lookup(virtual_network_rules.value, "ignore_missing_endpoint", false)
        }
      }
    }
  }

  # Identity
  dynamic "identity" {
    for_each = var.identity_type != null ? [1] : []
    content {
      type         = var.identity_type
      identity_ids = var.identity_ids
    }
  }

  # Customer-managed key
  dynamic "customer_managed_key" {
    for_each = var.customer_managed_key_id != null ? [1] : []
    content {
      key_vault_key_id   = var.customer_managed_key_id
      identity_client_id = var.identity_client_id
    }
  }

  # Storage for custom models
  dynamic "storage" {
    for_each = var.storage_account_id != null ? [1] : []
    content {
      storage_account_id = var.storage_account_id
      identity_client_id = var.storage_identity_client_id
    }
  }

  # Content filtering
  fqdns                         = var.fqdns
  local_auth_enabled            = var.local_auth_enabled
  outbound_network_access_restricted = var.outbound_network_access_restricted

  tags = var.common_tags
}
