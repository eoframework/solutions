#------------------------------------------------------------------------------
# Project Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 23:05:07
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

aws = {
  account_id = "123456789012"  # AWS account ID for platform
  dr_region = "us-west-2"  # DR AWS region for failover
  region = "us-east-1"  # Primary AWS region
}

ownership = {
  cost_center = "CC-TFE-001"  # Cost center for billing
  owner_email = "platform-team@example.com"  # Owner email for notifications
  project_code = "PRJ-TFE-001"  # Project tracking code
}
