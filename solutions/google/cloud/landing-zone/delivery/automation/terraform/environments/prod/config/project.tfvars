#------------------------------------------------------------------------------
# Project Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 22:21:03
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

gcp = {
  dr_region = "us-east1"  # DR GCP region
  project_id = "[PROJECT_ID]"  # GCP project ID for deployment
  region = "us-central1"  # Primary GCP region
  zone = "us-central1-a"  # Primary GCP zone
}

ownership = {
  cost_center = "CC-12345"  # Cost center for billing
  owner_email = "platform-team@example.com"  # Owner email for notifications
  project_code = "PRJ-GLZ-001"  # Project tracking code
}

solution = {
  abbr = "glz"  # Solution abbreviation (3-4 chars)
  category_name = "cloud"  # Solution category
  name = "gcp-landing-zone"  # Solution name for resource naming
  provider_name = "google"  # Provider organization name
}
