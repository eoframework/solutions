#------------------------------------------------------------------------------
# Monitoring Configuration - Test
#------------------------------------------------------------------------------
# Generated from configuration.csv Test column
# Minimal monitoring for test environment
#------------------------------------------------------------------------------

logging = {
  sink_type                = "BigQuery"
  retention_days           = 30
  bigquery_retention_years = 1
  volume_gb_month          = 100
  enable_audit_logs        = true
  enable_data_access_logs  = false
}

monitoring = {
  dashboard_count       = 2
  alert_policy_count    = 3
  notification_channels = ["email"]
  uptime_check_enabled  = false
  log_based_metrics     = false
}

budget = {
  enabled            = false
  monthly_amount     = 5000
  alert_thresholds   = [80, 100]
  currency           = "USD"
  notification_email = "finops@example.com"
}
