#------------------------------------------------------------------------------
# Backup Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 23:05:07
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

backup = {
  daily_retention = 1  # Daily backup retention (days)
  enable_cross_region = false  # Enable cross-region backup copy
  enabled = false  # Enable AWS Backup
  weekly_retention = 0  # Weekly backup retention (days)
}
