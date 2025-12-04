#------------------------------------------------------------------------------
# Monitoring Configuration - Production
#------------------------------------------------------------------------------
# Generated from configuration.csv Production column
#------------------------------------------------------------------------------

logging = {
  sink_type                = "BigQuery"
  retention_days           = 365
  bigquery_retention_years = 7
  volume_gb_month          = 500
  enable_audit_logs        = true
  enable_data_access_logs  = true
}

monitoring = {
  dashboard_count       = 4
  alert_policy_count    = 5
  notification_channels = ["email", "pagerduty"]
  uptime_check_enabled  = true
  log_based_metrics     = true
}

budget = {
  enabled            = true
  monthly_amount     = 50000
  alert_thresholds   = [50, 80, 100]
  currency           = "USD"
  notification_email = "finops@example.com"
}
