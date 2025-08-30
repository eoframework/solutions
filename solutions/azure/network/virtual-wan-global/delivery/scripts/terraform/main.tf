# Azure Virtual WAN Global Network Infrastructure
# Deploys Azure Virtual WAN with multiple regions, hubs, and connections

terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

# Data sources
data "azurerm_client_config" "current" {}

# Random suffix for unique naming
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "${var.project_name}-vwan-rg-${random_string.suffix.result}"
  location = var.primary_region

  tags = merge(var.common_tags, {
    Purpose = "Virtual WAN Infrastructure"
  })
}

# Virtual WAN
resource "azurerm_virtual_wan" "main" {
  name                           = "${var.project_name}-vwan-${random_string.suffix.result}"
  resource_group_name           = azurerm_resource_group.main.name
  location                      = azurerm_resource_group.main.location
  type                          = var.virtual_wan_type
  allow_branch_to_branch_traffic = var.allow_branch_to_branch_traffic

  tags = var.common_tags
}

# Virtual Hubs in multiple regions
resource "azurerm_virtual_hub" "hubs" {
  for_each = var.virtual_hubs

  name                = "${var.project_name}-vhub-${each.key}-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.main.name
  location            = each.value.location
  virtual_wan_id      = azurerm_virtual_wan.main.id
  address_prefix      = each.value.address_prefix
  sku                 = each.value.sku

  tags = var.common_tags
}

# VPN Gateways
resource "azurerm_vpn_gateway" "main" {
  for_each = {
    for k, v in var.virtual_hubs : k => v
    if v.deploy_vpn_gateway
  }

  name                = "${var.project_name}-vpngw-${each.key}-${random_string.suffix.result}"
  location            = azurerm_virtual_hub.hubs[each.key].location
  resource_group_name = azurerm_resource_group.main.name
  virtual_hub_id      = azurerm_virtual_hub.hubs[each.key].id
  scale_unit          = var.vpn_gateway_scale_unit

  tags = var.common_tags
}

# ExpressRoute Gateways  
resource "azurerm_express_route_gateway" "main" {
  for_each = {
    for k, v in var.virtual_hubs : k => v
    if v.deploy_expressroute_gateway
  }

  name                = "${var.project_name}-ergw-${each.key}-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_virtual_hub.hubs[each.key].location
  virtual_hub_id      = azurerm_virtual_hub.hubs[each.key].id
  scale_units         = var.expressroute_gateway_scale_units

  tags = var.common_tags
}

# Point-to-Site VPN Gateways
resource "azurerm_point_to_site_vpn_gateway" "main" {
  for_each = {
    for k, v in var.virtual_hubs : k => v
    if v.deploy_p2s_gateway
  }

  name                        = "${var.project_name}-p2sgw-${each.key}-${random_string.suffix.result}"
  location                    = azurerm_virtual_hub.hubs[each.key].location
  resource_group_name         = azurerm_resource_group.main.name
  virtual_hub_id              = azurerm_virtual_hub.hubs[each.key].id
  vpn_server_configuration_id = azurerm_vpn_server_configuration.main[each.key].id
  scale_unit                  = var.p2s_gateway_scale_unit

  connection_configuration {
    name               = "default"
    vpn_client_address_pool {
      address_prefixes = var.p2s_address_pools
    }
  }

  tags = var.common_tags
}

# VPN Server Configuration for P2S
resource "azurerm_vpn_server_configuration" "main" {
  for_each = {
    for k, v in var.virtual_hubs : k => v
    if v.deploy_p2s_gateway
  }

  name                     = "${var.project_name}-p2sconfig-${each.key}-${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_virtual_hub.hubs[each.key].location
  vpn_authentication_types = ["Certificate"]

  client_root_certificate {
    name             = "root-cert"
    public_cert_data = var.p2s_root_certificate
  }

  tags = var.common_tags
}

# Firewall Policy
resource "azurerm_firewall_policy" "main" {
  count = var.deploy_azure_firewall ? 1 : 0

  name                = "${var.project_name}-fw-policy-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = var.firewall_policy_sku

  dns {
    proxy_enabled = true
    servers       = var.custom_dns_servers
  }

  threat_intelligence_mode = var.threat_intelligence_mode

  tags = var.common_tags
}

# Firewall Policy Rules
resource "azurerm_firewall_policy_rule_collection_group" "main" {
  count = var.deploy_azure_firewall ? 1 : 0

  name               = "${var.project_name}-fw-rules-${random_string.suffix.result}"
  firewall_policy_id = azurerm_firewall_policy.main[0].id
  priority           = 500

  # Network Rule Collection
  network_rule_collection {
    name     = "network-rules"
    priority = 400
    action   = "Allow"

    rule {
      name                  = "allow-web-traffic"
      protocols             = ["TCP"]
      source_addresses      = ["*"]
      destination_addresses = ["*"]
      destination_ports     = ["80", "443"]
    }

    rule {
      name                  = "allow-dns"
      protocols             = ["UDP"]
      source_addresses      = ["*"]
      destination_addresses = ["*"]
      destination_ports     = ["53"]
    }
  }

  # Application Rule Collection
  application_rule_collection {
    name     = "application-rules"
    priority = 500
    action   = "Allow"

    rule {
      name = "allow-microsoft-services"
      protocols {
        type = "Http"
        port = 80
      }
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"]
      destination_fqdns = [
        "*.microsoft.com",
        "*.azure.com",
        "*.windows.net"
      ]
    }
  }
}

# Azure Firewall in Virtual Hubs
resource "azurerm_firewall" "main" {
  for_each = {
    for k, v in var.virtual_hubs : k => v
    if var.deploy_azure_firewall && v.deploy_firewall
  }

  name                = "${var.project_name}-fw-${each.key}-${random_string.suffix.result}"
  location            = azurerm_virtual_hub.hubs[each.key].location
  resource_group_name = azurerm_resource_group.main.name
  sku_name            = "AZFW_Hub"
  sku_tier            = var.firewall_sku_tier
  firewall_policy_id  = azurerm_firewall_policy.main[0].id

  virtual_hub {
    virtual_hub_id   = azurerm_virtual_hub.hubs[each.key].id
    public_ip_count  = var.firewall_public_ip_count
  }

  tags = var.common_tags
}

# Route Tables
resource "azurerm_virtual_hub_route_table" "main" {
  for_each = var.route_tables

  name           = each.key
  virtual_hub_id = azurerm_virtual_hub.hubs[each.value.hub_key].id
  labels         = each.value.labels

  dynamic "route" {
    for_each = each.value.routes
    content {
      name              = route.value.name
      destinations_type = route.value.destinations_type
      destinations      = route.value.destinations
      next_hop_type     = route.value.next_hop_type
      next_hop          = route.value.next_hop
    }
  }
}

# Hub Virtual Network Connections for spoke VNets
resource "azurerm_virtual_network" "spokes" {
  for_each = var.spoke_vnets

  name                = "${var.project_name}-vnet-${each.key}-${random_string.suffix.result}"
  location            = each.value.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = each.value.address_space

  tags = var.common_tags
}

# Subnets in spoke VNets
resource "azurerm_subnet" "spoke_subnets" {
  for_each = {
    for combo in flatten([
      for vnet_key, vnet in var.spoke_vnets : [
        for subnet_key, subnet in vnet.subnets : {
          key         = "${vnet_key}-${subnet_key}"
          vnet_key    = vnet_key
          subnet_key  = subnet_key
          subnet      = subnet
        }
      ]
    ]) : combo.key => combo
  }

  name                 = each.value.subnet_key
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.spokes[each.value.vnet_key].name
  address_prefixes     = each.value.subnet.address_prefixes
}

# Virtual Hub Connections to Spoke VNets
resource "azurerm_virtual_hub_connection" "spokes" {
  for_each = var.spoke_vnets

  name                      = "${each.key}-connection"
  virtual_hub_id            = azurerm_virtual_hub.hubs[each.value.hub_key].id
  remote_virtual_network_id = azurerm_virtual_network.spokes[each.key].id
  internet_security_enabled = each.value.internet_security_enabled

  dynamic "routing" {
    for_each = each.value.routing != null ? [each.value.routing] : []
    content {
      associated_route_table_id = routing.value.associated_route_table_id
      
      dynamic "propagated_route_table" {
        for_each = routing.value.propagated_route_tables != null ? [routing.value.propagated_route_tables] : []
        content {
          labels          = propagated_route_table.value.labels
          route_table_ids = propagated_route_table.value.route_table_ids
        }
      }

      dynamic "static_vnet_route" {
        for_each = routing.value.static_routes != null ? routing.value.static_routes : []
        content {
          name                = static_vnet_route.value.name
          address_prefixes    = static_vnet_route.value.address_prefixes
          next_hop_ip_address = static_vnet_route.value.next_hop_ip_address
        }
      }
    }
  }
}

# Log Analytics Workspace for monitoring
resource "azurerm_log_analytics_workspace" "main" {
  count = var.enable_monitoring ? 1 : 0

  name                = "${var.project_name}-law-${random_string.suffix.result}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_retention_days

  tags = var.common_tags
}

# Diagnostic Settings for Virtual WAN
resource "azurerm_monitor_diagnostic_setting" "vwan" {
  count = var.enable_monitoring ? 1 : 0

  name                       = "${var.project_name}-vwan-diag"
  target_resource_id         = azurerm_virtual_wan.main.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main[0].id

  enabled_log {
    category = "AuditEvent"
  }

  metric {
    category = "AllMetrics"
  }
}

# Diagnostic Settings for Virtual Hubs
resource "azurerm_monitor_diagnostic_setting" "vhubs" {
  for_each = var.enable_monitoring ? var.virtual_hubs : {}

  name                       = "${var.project_name}-vhub-${each.key}-diag"
  target_resource_id         = azurerm_virtual_hub.hubs[each.key].id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main[0].id

  enabled_log {
    category = "AuditEvent"
  }

  metric {
    category = "AllMetrics"
  }
}

# Network Security Groups for spoke subnets
resource "azurerm_network_security_group" "spoke_nsgs" {
  for_each = {
    for vnet_key, vnet in var.spoke_vnets : vnet_key => vnet
    if vnet.deploy_nsg
  }

  name                = "${var.project_name}-nsg-${each.key}-${random_string.suffix.result}"
  location            = each.value.location
  resource_group_name = azurerm_resource_group.main.name

  tags = var.common_tags
}

# Default NSG rules
resource "azurerm_network_security_rule" "default_rules" {
  for_each = {
    for vnet_key, vnet in var.spoke_vnets : vnet_key => vnet
    if vnet.deploy_nsg
  }

  name                        = "Allow-HTTPS-Inbound"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.spoke_nsgs[each.key].name
}

# Associate NSGs with subnets
resource "azurerm_subnet_network_security_group_association" "spoke_associations" {
  for_each = {
    for combo in flatten([
      for vnet_key, vnet in var.spoke_vnets : [
        for subnet_key, subnet in vnet.subnets : {
          key      = "${vnet_key}-${subnet_key}"
          vnet_key = vnet_key
          subnet   = subnet
        } if vnet.deploy_nsg && subnet.associate_nsg
      ]
    ]) : combo.key => combo
  }

  subnet_id                 = azurerm_subnet.spoke_subnets[each.key].id
  network_security_group_id = azurerm_network_security_group.spoke_nsgs[each.value.vnet_key].id
}