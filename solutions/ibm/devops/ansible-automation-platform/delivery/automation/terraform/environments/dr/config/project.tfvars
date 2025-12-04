#------------------------------------------------------------------------------
# Project Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-04 00:34:19
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

ownership = {
  cost_center = "CC-AAP-001"  # Cost center for billing
  owner_email = "automation-team@example.com"  # Owner email for notifications
  project_code = "PRJ-AAP-2025"  # Project code for tracking
}

solution = {
  abbr = "aap"  # Solution abbreviation (3-4 chars)
  category_name = "devops"  # Solution category
  name = "ansible-automation-platform"  # Solution name for resource naming
  provider_name = "ibm"  # Provider organization name
}
