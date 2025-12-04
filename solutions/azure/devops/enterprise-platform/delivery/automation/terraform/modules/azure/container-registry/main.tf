#------------------------------------------------------------------------------
# Azure Container Registry Module
#------------------------------------------------------------------------------
# Creates:
# - Azure Container Registry
# - Admin user (optional)
# - Replication (optional)
# - Private endpoint support
#------------------------------------------------------------------------------

resource "azurerm_container_registry" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku
  admin_enabled       = var.admin_enabled

  public_network_access_enabled = var.public_network_access_enabled
  quarantine_policy_enabled     = var.quarantine_policy_enabled
  zone_redundancy_enabled       = var.zone_redundancy_enabled

  # Network rule set (for Premium SKU)
  dynamic "network_rule_set" {
    for_each = var.sku == "Premium" && var.network_rule_set_enabled ? [1] : []
    content {
      default_action = var.network_default_action

      dynamic "ip_rule" {
        for_each = var.allowed_ip_ranges
        content {
          action   = "Allow"
          ip_range = ip_rule.value
        }
      }

      dynamic "virtual_network" {
        for_each = var.allowed_subnet_ids
        content {
          action    = "Allow"
          subnet_id = virtual_network.value
        }
      }
    }
  }

  # Identity
  dynamic "identity" {
    for_each = var.identity_type != null ? [1] : []
    content {
      type         = var.identity_type
      identity_ids = var.identity_type == "UserAssigned" ? var.identity_ids : null
    }
  }

  # Retention policy (Premium SKU only)
  dynamic "retention_policy" {
    for_each = var.sku == "Premium" && var.retention_days != null ? [1] : []
    content {
      days    = var.retention_days
      enabled = true
    }
  }

  # Trust policy (Premium SKU only)
  dynamic "trust_policy" {
    for_each = var.sku == "Premium" && var.trust_policy_enabled ? [1] : []
    content {
      enabled = true
    }
  }

  # Encryption (Premium SKU only)
  dynamic "encryption" {
    for_each = var.sku == "Premium" && var.encryption_enabled ? [1] : []
    content {
      enabled            = true
      key_vault_key_id   = var.encryption_key_vault_key_id
      identity_client_id = var.encryption_identity_client_id
    }
  }

  tags = var.common_tags
}

#------------------------------------------------------------------------------
# Georeplications (Premium SKU only)
#------------------------------------------------------------------------------
resource "azurerm_container_registry_georeplications" "this" {
  count = var.sku == "Premium" && length(var.georeplications) > 0 ? 1 : 0

  container_registry_name = azurerm_container_registry.this.name
  resource_group_name     = var.resource_group_name

  dynamic "georeplications" {
    for_each = var.georeplications
    content {
      location                = georeplications.value.location
      zone_redundancy_enabled = lookup(georeplications.value, "zone_redundancy_enabled", false)
      tags                    = var.common_tags
    }
  }
}

#------------------------------------------------------------------------------
# Webhooks
#------------------------------------------------------------------------------
resource "azurerm_container_registry_webhook" "this" {
  for_each = var.webhooks

  name                = each.key
  resource_group_name = var.resource_group_name
  registry_name       = azurerm_container_registry.this.name
  location            = var.location

  service_uri = each.value.service_uri
  status      = lookup(each.value, "status", "enabled")
  scope       = lookup(each.value, "scope", "")
  actions     = each.value.actions

  custom_headers = lookup(each.value, "custom_headers", {})

  tags = var.common_tags
}

#------------------------------------------------------------------------------
# Scope Maps (for token authentication)
#------------------------------------------------------------------------------
resource "azurerm_container_registry_scope_map" "this" {
  for_each = var.scope_maps

  name                    = each.key
  container_registry_name = azurerm_container_registry.this.name
  resource_group_name     = var.resource_group_name
  actions                 = each.value.actions
}

#------------------------------------------------------------------------------
# Tokens
#------------------------------------------------------------------------------
resource "azurerm_container_registry_token" "this" {
  for_each = var.tokens

  name                    = each.key
  container_registry_name = azurerm_container_registry.this.name
  resource_group_name     = var.resource_group_name
  scope_map_id            = azurerm_container_registry_scope_map.this[each.value.scope_map_name].id
  enabled                 = lookup(each.value, "enabled", true)
}
