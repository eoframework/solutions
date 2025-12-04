#------------------------------------------------------------------------------
# Project Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 17:57:13
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

aws = {
  dr_region = "us-east-1"  # DR region for cross-region resources
  profile = ""  # AWS CLI profile (optional)
  region = "us-west-2"  # AWS region for deployment
}

ownership = {
  cost_center = "CC-12345"  # Cost center for billing
  owner_email = "dr-team@company.com"  # Technical owner email
  project_code = "PRJ-DRWA-001"  # Project code for tracking
}

solution = {
  # Solution abbreviation for resource naming
  abbr = "drwa"
  category_name = "cloud"  # Solution category
  name = "DR Web Application"  # Full solution name for tagging
  provider_name = "aws"  # Cloud provider name
}
