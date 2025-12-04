#------------------------------------------------------------------------------
# Backup Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 23:05:08
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

backup = {
  daily_retention = 7  # Daily backup retention (days)
  enable_cross_region = false  # Enable cross-region backup copy
  enabled = true  # Enable AWS Backup
  weekly_retention = 30  # Weekly backup retention (days)
}
