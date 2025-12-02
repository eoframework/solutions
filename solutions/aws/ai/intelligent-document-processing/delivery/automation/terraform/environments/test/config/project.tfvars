#------------------------------------------------------------------------------
# Project Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-02 00:00:42
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

aws = {
  dr_region = "us-west-2"  # DR region
  profile = ""  # AWS CLI profile (optional)
  region = "us-east-1"  # Primary AWS region
}

ownership = {
  cost_center = "CC-IDP-001"  # Cost center
  owner_email = "idp-team@example.com"  # Owner email
  project_code = "PRJ-IDP-2025"  # Project code
}

solution = {
  abbr = "idp"  # Solution abbreviation (3-4 chars)
  category_name = "ai"  # Solution category
  name = "intelligent-document-processing"  # Solution name for resource naming
  provider_name = "aws"  # Provider organization name
}
