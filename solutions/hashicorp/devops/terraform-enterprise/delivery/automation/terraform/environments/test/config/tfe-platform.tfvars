#------------------------------------------------------------------------------
# Tfe Platform Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 23:05:07
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

tfe = {
  admin_email = "admin@example.com"  # Initial admin user email
  concurrent_runs = 5  # Maximum concurrent Terraform runs
  hostname = "tfe-test.client.example.com"  # TFE hostname (FQDN)
  license_path = "/secrets/tfe-license.rli"  # Path to TFE license file
  operational_mode = "standalone"  # TFE operational mode
  organization = "client-organization"  # TFE organization name
  user_count = 15  # Number of platform users
  workspace_count = 25  # Target workspace count for platform
}
