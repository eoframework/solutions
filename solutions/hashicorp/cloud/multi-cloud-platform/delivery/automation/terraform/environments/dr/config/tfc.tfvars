#------------------------------------------------------------------------------
# Terraform Cloud Configuration
# Generated from configuration.csv - DR values
#------------------------------------------------------------------------------

tfc = {
  organization     = "client-organization"
  hostname         = "app.terraform.io"
  workspace_prefix = "client-dr"
  vcs_provider     = "github"
  concurrent_runs  = 15
  user_count       = 50
  workspace_count  = 100
}
