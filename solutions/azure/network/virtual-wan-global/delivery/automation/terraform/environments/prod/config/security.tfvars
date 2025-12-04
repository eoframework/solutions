#------------------------------------------------------------------------------
# Security Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 18:36:44
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

security = {
  create_firewall_policy = true  # Create firewall policy
  dns_proxy_enabled = true  # Enable DNS proxy in firewall
  enable_firewall = true  # Enable Azure Firewall in hubs
  firewall_public_ip_count = 2  # Number of public IPs for firewall
  firewall_sku_tier = "Standard"  # Azure Firewall SKU tier
  intrusion_detection_mode = "Alert"  # Intrusion detection mode (Premium SKU)
  # Share policy between primary and secondary
  share_firewall_policy = true
  threat_intelligence_mode = "Alert"  # Threat intelligence mode
}
