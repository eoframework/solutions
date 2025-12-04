#------------------------------------------------------------------------------
# GitHub Actions Enterprise CI/CD - Test - Monitoring Configuration
#------------------------------------------------------------------------------

monitoring = {
  datadog_api_key           = "[dd-api-key]"
  datadog_app_key           = "[dd-app-key]"
  pagerduty_integration_key = "[pd-test-key]"
}

notifications = {
  slack_webhook_url = "[slack-test-webhook]"
  teams_webhook_url = "[teams-test-webhook]"
}

performance = {
  pipeline_target_duration  = 300
  deployment_success_target = 0.90
}
