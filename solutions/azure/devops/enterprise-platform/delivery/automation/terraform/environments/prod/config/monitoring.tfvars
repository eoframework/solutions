#------------------------------------------------------------------------------
# Monitoring Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 18:41:34
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

monitoring = {
  alert_email = "ops-team@company.com"  # Email for critical alerts
  enable_alerts = true  # Enable monitoring alerts
  enable_app_insights = true  # Enable Application Insights
  log_analytics_sku = "PerGB2018"  # Log Analytics Workspace SKU
  log_retention_days = 90  # Log retention in days
}
