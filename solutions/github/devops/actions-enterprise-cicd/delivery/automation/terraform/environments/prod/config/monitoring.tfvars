#------------------------------------------------------------------------------
# GitHub Actions Enterprise CI/CD - Production - Monitoring Configuration
#------------------------------------------------------------------------------
# Generated from configuration.csv - DO NOT EDIT DIRECTLY
# Use eof-tools/automation/scripts/generate-tfvars.py to regenerate
#
# NOTE: Sensitive values should be set via environment variables:
#   export TF_VAR_monitoring='{"datadog_api_key":"xxx",...}'
#   export TF_VAR_notifications='{"slack_webhook_url":"xxx",...}'
#------------------------------------------------------------------------------

monitoring = {
  datadog_api_key           = "[dd-api-key]"
  datadog_app_key           = "[dd-app-key]"
  pagerduty_integration_key = "[pd-prod-key]"
}

notifications = {
  slack_webhook_url = "[slack-prod-webhook]"
  teams_webhook_url = "[teams-prod-webhook]"
}

performance = {
  pipeline_target_duration  = 600
  deployment_success_target = 0.95
}
