#------------------------------------------------------------------------------
# Monitoring Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 23:05:07
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

monitoring = {
  datadog_enabled = true  # Enable Datadog integration
  enable_dashboard = true  # Create CloudWatch dashboard
  log_retention_days = 90  # CloudWatch log retention (days)
}
