#------------------------------------------------------------------------------
# Monitoring Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 22:21:04
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

monitoring = {
  alert_policy_count = 5  # Number of alert policies
  dashboard_count = 4  # Number of monitoring dashboards
  log_based_metrics = true  # Enable log-based metrics
  notification_channels = ["email", "pagerduty"]  # Notification channels
  uptime_check_enabled = true  # Enable uptime checks
}
