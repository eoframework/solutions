#------------------------------------------------------------------------------
# Tfe Platform Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 23:05:07
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

tfe = {
  admin_email = "admin@example.com"  # Initial admin user email
  concurrent_runs = 10  # Maximum concurrent Terraform runs
  hostname = "tfe.client.example.com"  # TFE hostname (FQDN)
  license_path = "/secrets/tfe-license.rli"  # Path to TFE license file
  operational_mode = "active-active"  # TFE operational mode
  organization = "client-organization"  # TFE organization name
  user_count = 25  # Number of platform users
  workspace_count = 50  # Target workspace count for platform
}
