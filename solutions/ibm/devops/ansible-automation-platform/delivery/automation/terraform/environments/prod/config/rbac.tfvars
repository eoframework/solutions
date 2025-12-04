#------------------------------------------------------------------------------
# Rbac Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-04 00:34:19
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

rbac = {
  admin_team = "Platform-Admins"  # Admin team name
  auditor_team = "Auditors"  # Auditor team name
  default_organization = "Default"  # Default organization name
  operator_team = "Operators"  # Operator team name
}
