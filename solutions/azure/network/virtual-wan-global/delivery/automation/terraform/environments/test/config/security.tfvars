#------------------------------------------------------------------------------
# Security Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 18:36:44
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

security = {
  create_firewall_policy = false  # Create firewall policy
  dns_proxy_enabled = false  # Enable DNS proxy in firewall
  enable_firewall = false  # Enable Azure Firewall in hubs
  firewall_public_ip_count = 1  # Number of public IPs for firewall
  firewall_sku_tier = "Standard"  # Azure Firewall SKU tier
  intrusion_detection_mode = "Off"  # Intrusion detection mode (Premium SKU)
  # Share policy between primary and secondary
  share_firewall_policy = false
  threat_intelligence_mode = "Off"  # Threat intelligence mode
}
