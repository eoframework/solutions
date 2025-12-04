#------------------------------------------------------------------------------
# Backup Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 23:05:07
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

backup = {
  daily_retention = 7  # Daily backup retention (days)
  enable_cross_region = true  # Enable cross-region backup copy
  enabled = true  # Enable AWS Backup
  weekly_retention = 30  # Weekly backup retention (days)
}
