#------------------------------------------------------------------------------
# Monitoring Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 18:40:17
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

monitoring = {
  alert_email = "ops-team@company.com"  # Email for critical alerts
  enable_alerts = true  # Enable monitoring alerts
  enable_dashboard = true  # Enable Azure dashboard
  health_check_interval = 300  # Health check frequency in seconds
  log_retention_days = 90  # Log retention in days
}
