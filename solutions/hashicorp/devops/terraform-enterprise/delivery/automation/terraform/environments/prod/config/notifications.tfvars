#------------------------------------------------------------------------------
# Notifications Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 23:05:07
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

integration = {
  pagerduty_enabled = true  # Enable PagerDuty integration
  slack_enabled = true  # Enable Slack notifications
}
