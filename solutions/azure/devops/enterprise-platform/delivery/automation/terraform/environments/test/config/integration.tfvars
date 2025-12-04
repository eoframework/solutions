#------------------------------------------------------------------------------
# Integration Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 18:41:35
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

integration = {
  servicenow_enabled = false  # Enable ServiceNow integration
  sonarcloud_org = "[SONARCLOUD_ORG]"  # SonarCloud organization key
  teams_webhook_enabled = false  # Enable Microsoft Teams notifications
}
