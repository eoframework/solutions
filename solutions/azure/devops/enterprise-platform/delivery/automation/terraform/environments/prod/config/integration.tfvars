#------------------------------------------------------------------------------
# Integration Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 18:41:34
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

integration = {
  servicenow_enabled = true  # Enable ServiceNow integration
  sonarcloud_org = "[SONARCLOUD_ORG]"  # SonarCloud organization key
  teams_webhook_enabled = true  # Enable Microsoft Teams notifications
}
