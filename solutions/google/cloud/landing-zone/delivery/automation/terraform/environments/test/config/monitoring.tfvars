#------------------------------------------------------------------------------
# Monitoring Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 22:21:03
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

monitoring = {
  alert_policy_count = 3  # Number of alert policies
  dashboard_count = 2  # Number of monitoring dashboards
  log_based_metrics = false  # Enable log-based metrics
  notification_channels = ["email"]  # Notification channels
  uptime_check_enabled = false  # Enable uptime checks
}
