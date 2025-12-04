#------------------------------------------------------------------------------
# GitHub Advanced Security - Test - Integration Configuration
#------------------------------------------------------------------------------
# Generated from configuration.csv - DO NOT EDIT DIRECTLY
# Use eof-tools/automation/scripts/generate-tfvars.py to regenerate
#------------------------------------------------------------------------------

integration = {
  siem_webhook_url      = "[siem-test-endpoint]"
  siem_webhook_secret   = "[webhook-test-secret]"
  siem_event_types      = "code-scanning,secret-scanning"
  siem_platform         = "Azure Sentinel"
  splunk_hec_url        = "[splunk-test-url]"
  splunk_hec_token      = "[splunk-test-token]"
  sentinel_workspace_id = "[sentinel-test-workspace]"
  sentinel_shared_key   = "[sentinel-test-key]"
  jira_base_url         = "[jira-test-url]"
  jira_project_key      = "[test-project-key]"
  jira_api_token        = "[jira-test-token]"
  servicenow_url        = "[servicenow-test-url]"
  servicenow_api_key    = "[servicenow-test-key]"
}

notifications = {
  slack_webhook_url      = "[slack-test-webhook]"
  teams_webhook_url      = "[teams-test-webhook]"
  pagerduty_routing_key  = "[pagerduty-test-key]"
  alert_email_recipients = "dev-team@company.com"
  email_enabled          = true
  slack_enabled          = true
  teams_enabled          = false
  pagerduty_enabled      = false
}
