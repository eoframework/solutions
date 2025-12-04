#------------------------------------------------------------------------------
# Terraform Cloud Configuration
# Generated from configuration.csv - Test values
#------------------------------------------------------------------------------

tfc = {
  organization     = "client-organization"
  hostname         = "app.terraform.io"
  workspace_prefix = "client-test"
  vcs_provider     = "github"
  concurrent_runs  = 5
  user_count       = 25
  workspace_count  = 50
}
