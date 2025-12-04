#------------------------------------------------------------------------------
# GitHub Advanced Security - Production - DR Configuration
#------------------------------------------------------------------------------
# Generated from configuration.csv - DO NOT EDIT DIRECTLY
# Use eof-tools/automation/scripts/generate-tfvars.py to regenerate
#------------------------------------------------------------------------------

dr = {
  enabled             = true
  organization_name   = "[dr-org-name]"
  replication_enabled = true
  failover_priority   = 1
}
