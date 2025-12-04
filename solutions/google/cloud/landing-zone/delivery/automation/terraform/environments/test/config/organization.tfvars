#------------------------------------------------------------------------------
# Organization Configuration - Test
#------------------------------------------------------------------------------
# Generated from configuration.csv Test column
#------------------------------------------------------------------------------

organization = {
  org_id             = "[ORG_ID]"
  domain             = "example.com"
  billing_account_id = "[BILLING_ACCOUNT_ID]"
  display_name       = "Example Organization Test"
}

folders = {
  dev_display_name     = "Development"
  staging_display_name = "Staging"
  prod_display_name    = "Production"
  shared_display_name  = "Shared Services"
  sandbox_display_name = "Sandbox"
}

projects = {
  host_project_name       = "host-vpc-test"
  logging_project_name    = "logging-test"
  security_project_name   = "security-test"
  monitoring_project_name = "monitoring-test"
  initial_count           = 5
  team_count              = 3
}
