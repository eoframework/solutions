#------------------------------------------------------------------------------
# Security Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 22:21:04
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

security = {
  blocked_countries = []  # Blocked country codes
  chronicle_enabled = true  # Enable Chronicle SIEM
  chronicle_ingestion_volume = "100 GB/month"  # Monthly log ingestion volume
  chronicle_retention = "12 months"  # Log retention period
  cloud_armor_enabled = true  # Enable Cloud Armor
  cloud_armor_owasp_rules = true  # Enable OWASP ModSecurity rules
  cloud_armor_rate_limiting = true  # Enable rate limiting rules
  cloud_ids_enabled = true  # Enable Cloud IDS
  cloud_ids_endpoints = 3  # Number of Cloud IDS endpoints
  rate_limit_ban_duration_sec = 600  # Rate limit ban duration (seconds)
  rate_limit_requests_per_minute = 1000  # Rate limit threshold (requests/min)
  scc_asset_discovery = true  # Enable asset discovery
  scc_notifications_enabled = false  # Enable SCC Pub/Sub notifications
  scc_public_resource_detection = true  # Enable public resource detection
  scc_tier = "Premium"  # Security Command Center tier
}
