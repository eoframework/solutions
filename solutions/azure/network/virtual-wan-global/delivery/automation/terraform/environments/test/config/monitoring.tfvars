#------------------------------------------------------------------------------
# Monitoring Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 18:36:44
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

monitoring = {
  alert_email = "dev-team@company.com"  # Email address for alerts
  enable_alerts = false  # Enable monitoring alerts
  enable_network_watcher = false  # Enable Network Watcher
  log_analytics_sku = "PerGB2018"  # Log Analytics Workspace SKU
  log_retention_days = 30  # Log retention in days
}
