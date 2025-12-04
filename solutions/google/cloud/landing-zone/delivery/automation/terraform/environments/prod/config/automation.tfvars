#------------------------------------------------------------------------------
# Automation Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 22:21:02
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

automation = {
  project_provisioning_target = "<1 hour"  # Target project provisioning time
  state_bucket_location = "US"  # State bucket location
  state_bucket_name = "terraform-state-glz-prod"  # Terraform state bucket name
  terraform_version = ">= 1.6.0"  # Minimum Terraform version
}
