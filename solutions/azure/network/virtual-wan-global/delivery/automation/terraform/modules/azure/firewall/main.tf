#------------------------------------------------------------------------------
# Azure Firewall Module (Virtual Hub)
#------------------------------------------------------------------------------

resource "azurerm_firewall" "main" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku_name            = var.sku_name
  sku_tier            = var.sku_tier
  firewall_policy_id  = var.firewall_policy_id

  virtual_hub {
    virtual_hub_id  = var.virtual_hub_id
    public_ip_count = var.public_ip_count
  }

  tags = var.tags
}

# Firewall Policy
resource "azurerm_firewall_policy" "main" {
  count               = var.create_policy ? 1 : 0
  name                = "${var.name}-policy"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku_tier

  dns {
    proxy_enabled = var.dns_proxy_enabled
    servers       = var.dns_servers
  }

  threat_intelligence_mode = var.threat_intelligence_mode

  intrusion_detection {
    mode = var.intrusion_detection_mode

    dynamic "signature_overrides" {
      for_each = var.signature_overrides
      content {
        id    = signature_overrides.value.id
        state = signature_overrides.value.state
      }
    }

    dynamic "traffic_bypass" {
      for_each = var.traffic_bypass
      content {
        name                  = traffic_bypass.value.name
        protocol              = traffic_bypass.value.protocol
        destination_addresses = traffic_bypass.value.destination_addresses
        destination_ports     = traffic_bypass.value.destination_ports
        source_addresses      = traffic_bypass.value.source_addresses
      }
    }
  }

  tags = var.tags
}

# Network Rule Collection
resource "azurerm_firewall_policy_rule_collection_group" "network" {
  count              = var.create_policy && length(var.network_rule_collections) > 0 ? 1 : 0
  name               = "${var.name}-network-rules"
  firewall_policy_id = azurerm_firewall_policy.main[0].id
  priority           = 100

  dynamic "network_rule_collection" {
    for_each = var.network_rule_collections
    content {
      name     = network_rule_collection.value.name
      priority = network_rule_collection.value.priority
      action   = network_rule_collection.value.action

      dynamic "rule" {
        for_each = network_rule_collection.value.rules
        content {
          name                  = rule.value.name
          protocols             = rule.value.protocols
          source_addresses      = rule.value.source_addresses
          destination_addresses = rule.value.destination_addresses
          destination_ports     = rule.value.destination_ports
        }
      }
    }
  }
}

# Application Rule Collection
resource "azurerm_firewall_policy_rule_collection_group" "application" {
  count              = var.create_policy && length(var.application_rule_collections) > 0 ? 1 : 0
  name               = "${var.name}-application-rules"
  firewall_policy_id = azurerm_firewall_policy.main[0].id
  priority           = 200

  dynamic "application_rule_collection" {
    for_each = var.application_rule_collections
    content {
      name     = application_rule_collection.value.name
      priority = application_rule_collection.value.priority
      action   = application_rule_collection.value.action

      dynamic "rule" {
        for_each = application_rule_collection.value.rules
        content {
          name              = rule.value.name
          source_addresses  = rule.value.source_addresses
          destination_fqdns = rule.value.destination_fqdns

          dynamic "protocols" {
            for_each = rule.value.protocols
            content {
              type = protocols.value.type
              port = protocols.value.port
            }
          }
        }
      }
    }
  }
}
