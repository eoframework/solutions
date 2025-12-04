#------------------------------------------------------------------------------
# Project Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-04 00:34:03
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

ownership = {
  cost_center = "CC-OCP-001"  # Cost center for billing
  owner_email = "platform-team@example.com"  # Owner email for notifications
  project_code = "PRJ-OCP-2025"  # Project code for tracking
}

solution = {
  abbr = "ocp"  # Solution abbreviation (3-4 chars)
  category_name = "cloud"  # Solution category
  name = "openshift-container-platform"  # Solution name for resource naming
  provider_name = "ibm"  # Provider organization name
}
