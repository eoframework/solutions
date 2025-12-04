#------------------------------------------------------------------------------
# Monitoring Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-04 00:34:19
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

monitoring = {
  insights_enabled = true  # Enable Red Hat Insights
  log_aggregator_enabled = true  # Enable log aggregation
  log_aggregator_host = "splunk.example.com"  # Log aggregator hostname
  log_aggregator_port = 9997  # Log aggregator port
  log_aggregator_type = "splunk"  # Log aggregator type
  pagerduty_enabled = true  # Enable PagerDuty integration
}
