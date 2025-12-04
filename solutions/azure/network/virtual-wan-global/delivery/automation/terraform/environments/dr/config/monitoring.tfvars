#------------------------------------------------------------------------------
# Monitoring Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 18:36:45
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

monitoring = {
  alert_email = "ops-team@company.com"  # Email address for alerts
  enable_alerts = true  # Enable monitoring alerts
  enable_network_watcher = true  # Enable Network Watcher
  log_analytics_sku = "PerGB2018"  # Log Analytics Workspace SKU
  log_retention_days = 90  # Log retention in days
}
