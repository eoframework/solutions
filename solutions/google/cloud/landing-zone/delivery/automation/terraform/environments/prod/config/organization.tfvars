#------------------------------------------------------------------------------
# Organization Configuration - Production
#------------------------------------------------------------------------------
# Generated from configuration.csv Production column
#------------------------------------------------------------------------------

organization = {
  org_id             = "[ORG_ID]"
  domain             = "example.com"
  billing_account_id = "[BILLING_ACCOUNT_ID]"
  display_name       = "Example Organization"
}

folders = {
  dev_display_name     = "Development"
  staging_display_name = "Staging"
  prod_display_name    = "Production"
  shared_display_name  = "Shared Services"
  sandbox_display_name = "Sandbox"
}

projects = {
  host_project_name       = "host-vpc-prod"
  logging_project_name    = "logging-prod"
  security_project_name   = "security-prod"
  monitoring_project_name = "monitoring-prod"
  initial_count           = 10
  team_count              = 5
}
