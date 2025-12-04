#------------------------------------------------------------------------------
# Monitoring Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 18:26:49
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

monitoring = {
  alert_email = "dev-team@company.com"  # Email for critical alerts
  enable_alerts = false  # Enable monitoring alerts
  enable_dashboard = false  # Enable Azure dashboard
  health_check_interval = 600  # Health check frequency in seconds
  log_retention_days = 30  # Log retention in days
}
