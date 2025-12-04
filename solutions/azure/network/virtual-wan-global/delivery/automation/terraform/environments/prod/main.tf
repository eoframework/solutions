#------------------------------------------------------------------------------
# Azure Virtual WAN Global - Production Environment
#------------------------------------------------------------------------------
# Global network infrastructure with:
# - Azure Virtual WAN with multi-region hubs
# - VPN Gateways for site-to-site connectivity
# - ExpressRoute Gateways for private connectivity
# - Azure Firewall for security and traffic inspection
# - Network monitoring and analytics
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Locals
#------------------------------------------------------------------------------
locals {
  environment = basename(path.module)
  name_prefix = "${var.solution.abbr}-${local.environment}"

  # Environment display name mapping
  env_display_name = {
    prod = "Production"
    test = "Test"
    dr   = "Disaster Recovery"
  }

  #----------------------------------------------------------------------------
  # Shared Configuration Objects
  #----------------------------------------------------------------------------
  project = {
    name        = var.solution.abbr
    environment = local.environment
  }

  common_tags = {
    Solution     = var.solution.name
    SolutionAbbr = var.solution.abbr
    Environment  = local.environment
    Provider     = var.solution.provider_name
    Category     = var.solution.category_name
    Region       = var.azure.region
    ManagedBy    = "terraform"
    CostCenter   = var.ownership.cost_center
    Owner        = var.ownership.owner_email
    ProjectCode  = var.ownership.project_code
  }

  # Computed BGP settings from connectivity variables
  vpn_bgp_settings = {
    asn         = var.connectivity.vpn_bgp_asn
    peer_weight = var.connectivity.vpn_bgp_peer_weight
  }
  vpn_bgp_settings_secondary = {
    asn         = var.connectivity.vpn_bgp_asn
    peer_weight = var.connectivity.vpn_bgp_peer_weight
  }
}

#------------------------------------------------------------------------------
# Data Sources
#------------------------------------------------------------------------------
data "azurerm_client_config" "current" {}
data "azurerm_subscription" "current" {}

#===============================================================================
# FOUNDATION - Core Virtual WAN infrastructure
#===============================================================================
#------------------------------------------------------------------------------
# Core Infrastructure (Resource Group, Virtual WAN, Virtual Hubs)
#------------------------------------------------------------------------------
module "core" {
  source = "../../modules/solution/core"

  name_prefix        = local.name_prefix
  location           = var.azure.region
  secondary_location = var.azure.secondary_region
  common_tags        = local.common_tags

  # Virtual WAN Configuration
  wan_type                          = var.vwan.type
  allow_branch_to_branch_traffic    = var.vwan.allow_branch_to_branch
  office365_local_breakout_category = var.vwan.office365_breakout

  # Virtual Hub Configuration
  hub_sku                      = var.vwan.hub_sku
  hub_routing_preference       = var.vwan.hub_routing_preference
  enable_secondary_hub         = var.vwan.enable_secondary_hub
  primary_hub_address_prefix   = var.vwan.primary_hub_prefix
  secondary_hub_address_prefix = var.vwan.secondary_hub_prefix
  create_custom_route_tables   = var.vwan.create_custom_route_tables
}

#===============================================================================
# CONNECTIVITY - Gateways for VPN and ExpressRoute
#===============================================================================
#------------------------------------------------------------------------------
# Connectivity (VPN Gateways, ExpressRoute Gateways)
#------------------------------------------------------------------------------
module "connectivity" {
  source = "../../modules/solution/connectivity"

  name_prefix          = local.name_prefix
  resource_group_name  = module.core.resource_group_name
  primary_location     = var.azure.region
  secondary_location   = var.azure.secondary_region
  primary_hub_id       = module.core.primary_hub_id
  secondary_hub_id     = module.core.secondary_hub_id
  enable_secondary_hub = var.vwan.enable_secondary_hub
  common_tags          = local.common_tags

  # VPN Gateway Configuration
  enable_vpn_gateway       = var.connectivity.enable_vpn_gateway
  vpn_gateway_scale_unit   = var.connectivity.vpn_gateway_scale_unit
  vpn_routing_preference   = var.connectivity.vpn_routing_preference
  vpn_bgp_settings         = local.vpn_bgp_settings
  vpn_bgp_settings_secondary = local.vpn_bgp_settings_secondary

  # ExpressRoute Gateway Configuration
  enable_expressroute_gateway = var.connectivity.enable_expressroute_gateway
  er_gateway_scale_units      = var.connectivity.er_gateway_scale_units
  er_allow_non_vwan_traffic   = var.connectivity.er_allow_non_vwan_traffic

  depends_on = [module.core]
}

#===============================================================================
# SECURITY - Firewall and policies
#===============================================================================
#------------------------------------------------------------------------------
# Security (Azure Firewall, Firewall Policies)
#------------------------------------------------------------------------------
module "security" {
  source = "../../modules/solution/security"

  name_prefix          = local.name_prefix
  resource_group_name  = module.core.resource_group_name
  primary_location     = var.azure.region
  secondary_location   = var.azure.secondary_region
  primary_hub_id       = module.core.primary_hub_id
  secondary_hub_id     = module.core.secondary_hub_id
  enable_secondary_hub = var.vwan.enable_secondary_hub
  common_tags          = local.common_tags

  # Firewall Configuration
  enable_firewall           = var.security.enable_firewall
  firewall_sku_tier         = var.security.firewall_sku_tier
  firewall_public_ip_count  = var.security.firewall_public_ip_count
  create_firewall_policy    = var.security.create_firewall_policy
  share_firewall_policy     = var.security.share_firewall_policy

  # Firewall Policy Configuration
  dns_proxy_enabled         = var.security.dns_proxy_enabled
  dns_servers               = var.security.dns_servers
  threat_intelligence_mode  = var.security.threat_intelligence_mode
  intrusion_detection_mode  = var.security.intrusion_detection_mode
  network_rule_collections  = var.security.network_rule_collections
  application_rule_collections = var.security.application_rule_collections

  depends_on = [module.core]
}

#===============================================================================
# MONITORING - Observability and analytics
#===============================================================================
#------------------------------------------------------------------------------
# Monitoring (Log Analytics, Network Watcher, Alerts)
#------------------------------------------------------------------------------
module "monitoring" {
  source = "../../modules/solution/monitoring"

  name_prefix          = local.name_prefix
  resource_group_name  = module.core.resource_group_name
  location             = var.azure.region
  secondary_location   = var.azure.secondary_region
  common_tags          = local.common_tags

  # Log Analytics Configuration
  log_analytics_sku     = var.monitoring.log_analytics_sku
  log_retention_days    = var.monitoring.log_retention_days

  # Alerting Configuration
  enable_alerts         = var.monitoring.enable_alerts
  alert_email           = var.monitoring.alert_email

  # Resource IDs for Diagnostic Settings
  virtual_wan_id        = module.core.virtual_wan_id
  primary_hub_id        = module.core.primary_hub_id
  secondary_hub_id      = module.core.secondary_hub_id
  primary_firewall_id   = module.security.primary_firewall_id
  secondary_firewall_id = module.security.secondary_firewall_id
  primary_vpn_gateway_id = module.connectivity.primary_vpn_gateway_id
  secondary_vpn_gateway_id = module.connectivity.secondary_vpn_gateway_id

  # Network Watcher
  enable_network_watcher = var.monitoring.enable_network_watcher

  depends_on = [module.security, module.connectivity]
}
