#------------------------------------------------------------------------------
# Organization Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 22:21:03
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

organization = {
  billing_account_id = "[BILLING_ACCOUNT_ID]"  # Billing account for all projects
  display_name = "Example Organization Test"  # Organization display name
  domain = "example.com"  # Primary domain for Cloud Identity
  org_id = "[ORG_ID]"  # GCP Organization resource identifier
}
