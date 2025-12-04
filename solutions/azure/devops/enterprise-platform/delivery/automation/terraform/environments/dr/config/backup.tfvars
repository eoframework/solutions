#------------------------------------------------------------------------------
# Backup Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 18:41:38
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

backup = {
  enabled = true  # Enable backup services
  retention_days = 30  # Backup retention in days
}
