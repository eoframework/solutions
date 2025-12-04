#------------------------------------------------------------------------------
# GitHub Actions Enterprise CI/CD - Production - DR Configuration
#------------------------------------------------------------------------------
# Generated from configuration.csv - DO NOT EDIT DIRECTLY
# Use eof-tools/automation/scripts/generate-tfvars.py to regenerate
#------------------------------------------------------------------------------

dr = {
  enabled           = true
  failover_priority = 1
}
