#------------------------------------------------------------------------------
# GitHub Advanced Security - Production - Integration Configuration
#------------------------------------------------------------------------------
# Generated from configuration.csv - DO NOT EDIT DIRECTLY
# Use eof-tools/automation/scripts/generate-tfvars.py to regenerate
#
# NOTE: Sensitive values should be set via environment variables:
#   export TF_VAR_auth='{"api_token":"ghp_xxx",...}'
#   export TF_VAR_integration='{"siem_webhook_secret":"xxx",...}'
#------------------------------------------------------------------------------

integration = {
  siem_webhook_url      = "[siem-webhook-endpoint]"
  siem_webhook_secret   = "[webhook-secret]"
  siem_event_types      = "code-scanning,secret-scanning,dependabot"
  siem_platform         = "Splunk"
  splunk_hec_url        = "[splunk-hec-url]"
  splunk_hec_token      = "[splunk-hec-token]"
  sentinel_workspace_id = "[sentinel-workspace-id]"
  sentinel_shared_key   = "[sentinel-shared-key]"
  jira_base_url         = "[jira-instance-url]"
  jira_project_key      = "[project-key]"
  jira_api_token        = "[jira-api-token]"
  servicenow_url        = "[servicenow-url]"
  servicenow_api_key    = "[servicenow-key]"
}

notifications = {
  slack_webhook_url      = "[slack-webhook-url]"
  teams_webhook_url      = "[teams-webhook-url]"
  pagerduty_routing_key  = "[pagerduty-key]"
  alert_email_recipients = "security-team@company.com"
  email_enabled          = true
  slack_enabled          = true
  teams_enabled          = false
  pagerduty_enabled      = true
}
