#------------------------------------------------------------------------------
# Monitoring Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 18:41:35
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

monitoring = {
  alert_email = "dev-team@company.com"  # Email for critical alerts
  enable_alerts = false  # Enable monitoring alerts
  enable_app_insights = true  # Enable Application Insights
  log_analytics_sku = "PerGB2018"  # Log Analytics Workspace SKU
  log_retention_days = 30  # Log retention in days
}
