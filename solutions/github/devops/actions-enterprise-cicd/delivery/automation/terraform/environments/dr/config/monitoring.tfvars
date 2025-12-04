#------------------------------------------------------------------------------
# GitHub Actions Enterprise CI/CD - DR - Monitoring Configuration
#------------------------------------------------------------------------------

monitoring = {
  datadog_api_key           = "[dd-api-key]"
  datadog_app_key           = "[dd-app-key]"
  pagerduty_integration_key = "[pd-dr-key]"
}

notifications = {
  slack_webhook_url = "[slack-dr-webhook]"
  teams_webhook_url = "[teams-dr-webhook]"
}

performance = {
  pipeline_target_duration  = 600
  deployment_success_target = 0.95
}
