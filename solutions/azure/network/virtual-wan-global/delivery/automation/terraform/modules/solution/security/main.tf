#------------------------------------------------------------------------------
# Virtual WAN Security Module
# Creates: Azure Firewall and Policies in both hubs
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Primary Hub - Azure Firewall
#------------------------------------------------------------------------------
module "primary_firewall" {
  count  = var.enable_firewall ? 1 : 0
  source = "../../azure/firewall"

  name                = "${var.name_prefix}-fw-primary"
  resource_group_name = var.resource_group_name
  location            = var.primary_location
  sku_name            = "AZFW_Hub"
  sku_tier            = var.firewall_sku_tier
  virtual_hub_id      = var.primary_hub_id
  public_ip_count     = var.firewall_public_ip_count

  create_policy               = var.create_firewall_policy
  dns_proxy_enabled           = var.dns_proxy_enabled
  dns_servers                 = var.dns_servers
  threat_intelligence_mode    = var.threat_intelligence_mode
  intrusion_detection_mode    = var.intrusion_detection_mode
  signature_overrides         = var.signature_overrides
  traffic_bypass              = var.traffic_bypass
  network_rule_collections    = var.network_rule_collections
  application_rule_collections = var.application_rule_collections

  tags = var.common_tags
}

#------------------------------------------------------------------------------
# Secondary Hub - Azure Firewall
#------------------------------------------------------------------------------
module "secondary_firewall" {
  count  = var.enable_firewall && var.enable_secondary_hub ? 1 : 0
  source = "../../azure/firewall"

  name                = "${var.name_prefix}-fw-secondary"
  resource_group_name = var.resource_group_name
  location            = var.secondary_location
  sku_name            = "AZFW_Hub"
  sku_tier            = var.firewall_sku_tier
  virtual_hub_id      = var.secondary_hub_id
  public_ip_count     = var.firewall_public_ip_count

  # Reuse policy from primary firewall if sharing policies
  create_policy               = var.share_firewall_policy ? false : var.create_firewall_policy
  firewall_policy_id          = var.share_firewall_policy ? module.primary_firewall[0].policy_id : null

  # Only configure these if creating a separate policy
  dns_proxy_enabled           = var.share_firewall_policy ? null : var.dns_proxy_enabled
  dns_servers                 = var.share_firewall_policy ? null : var.dns_servers
  threat_intelligence_mode    = var.share_firewall_policy ? null : var.threat_intelligence_mode
  intrusion_detection_mode    = var.share_firewall_policy ? null : var.intrusion_detection_mode
  signature_overrides         = var.share_firewall_policy ? [] : var.signature_overrides
  traffic_bypass              = var.share_firewall_policy ? [] : var.traffic_bypass
  network_rule_collections    = var.share_firewall_policy ? [] : var.network_rule_collections
  application_rule_collections = var.share_firewall_policy ? [] : var.application_rule_collections

  tags = var.common_tags

  depends_on = [module.primary_firewall]
}
