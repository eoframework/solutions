#------------------------------------------------------------------------------
# Organization Configuration - DR
#------------------------------------------------------------------------------
# Generated from configuration.csv DR column
#------------------------------------------------------------------------------

organization = {
  org_id             = "[ORG_ID]"
  domain             = "example.com"
  billing_account_id = "[BILLING_ACCOUNT_ID]"
  display_name       = "Example Organization DR"
}

folders = {
  dev_display_name     = "Development"
  staging_display_name = "Staging"
  prod_display_name    = "Production"
  shared_display_name  = "Shared Services"
  sandbox_display_name = "Sandbox"
}

projects = {
  host_project_name       = "host-vpc-dr"
  logging_project_name    = "logging-dr"
  security_project_name   = "security-dr"
  monitoring_project_name = "monitoring-dr"
  initial_count           = 5
  team_count              = 3
}
