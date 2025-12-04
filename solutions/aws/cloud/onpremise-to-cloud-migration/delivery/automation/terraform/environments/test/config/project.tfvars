#------------------------------------------------------------------------------
# Project Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 17:52:48
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

aws = {
  dr_region = "us-west-2"  # DR region for cross-region resources
  profile = ""  # AWS CLI profile (optional)
  region = "us-east-1"  # AWS region for deployment
}

ownership = {
  cost_center = "CC-MIG-001"  # Cost center for billing
  owner_email = "migration-team@company.com"  # Technical owner email
  project_code = "PRJ-CMIG-2025"  # Project code for tracking
}

solution = {
  # Solution abbreviation for resource naming
  abbr = "cmig"
  category_name = "cloud"  # Solution category
  name = "Cloud Migration"  # Full solution name for tagging
  provider_name = "aws"  # Cloud provider name
}
