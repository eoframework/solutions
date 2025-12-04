#------------------------------------------------------------------------------
# Security Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 22:21:03
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

security = {
  blocked_countries = []  # Blocked country codes
  chronicle_enabled = false  # Enable Chronicle SIEM
  chronicle_ingestion_volume = "0"  # Monthly log ingestion volume
  chronicle_retention = "0"  # Log retention period
  cloud_armor_enabled = false  # Enable Cloud Armor
  cloud_armor_owasp_rules = false  # Enable OWASP ModSecurity rules
  cloud_armor_rate_limiting = false  # Enable rate limiting rules
  cloud_ids_enabled = false  # Enable Cloud IDS
  cloud_ids_endpoints = 0  # Number of Cloud IDS endpoints
  rate_limit_ban_duration_sec = 0  # Rate limit ban duration (seconds)
  rate_limit_requests_per_minute = 0  # Rate limit threshold (requests/min)
  scc_asset_discovery = true  # Enable asset discovery
  scc_notifications_enabled = false  # Enable SCC Pub/Sub notifications
  scc_public_resource_detection = false  # Enable public resource detection
  scc_tier = "Standard"  # Security Command Center tier
}
