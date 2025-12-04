#------------------------------------------------------------------------------
# Project Configuration - Test
#------------------------------------------------------------------------------
# Generated from configuration.csv Test column
#------------------------------------------------------------------------------

solution = {
  name          = "gcp-landing-zone"
  abbr          = "glz"
  provider_name = "google"
  category_name = "cloud"
}

gcp = {
  project_id = "[PROJECT_ID]"
  region     = "us-central1"
  dr_region  = "us-east1"
  zone       = "us-central1-a"
}

ownership = {
  cost_center  = "CC-12345"
  owner_email  = "platform-team@example.com"
  project_code = "PRJ-GLZ-001"
}
