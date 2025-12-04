#------------------------------------------------------------------------------
# Automation Configuration - Test
#------------------------------------------------------------------------------

automation = {
  terraform_version           = ">= 1.6.0"
  state_bucket_name           = "terraform-state-glz-test"
  state_bucket_location       = "US"
  project_provisioning_target = "<1 hour"
}
