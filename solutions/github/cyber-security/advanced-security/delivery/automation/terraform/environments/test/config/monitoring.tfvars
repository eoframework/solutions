#------------------------------------------------------------------------------
# GitHub Advanced Security - Test - Monitoring Configuration
#------------------------------------------------------------------------------
# Generated from configuration.csv - DO NOT EDIT DIRECTLY
# Use eof-tools/automation/scripts/generate-tfvars.py to regenerate
#------------------------------------------------------------------------------

monitoring = {
  audit_log_retention_days  = 90
  metrics_enabled           = true
  security_overview_enabled = true
  alerts_enabled            = false
  dashboard_enabled         = false
  log_level                 = "DEBUG"
  health_check_interval     = 600
}

compliance = {
  frameworks       = "SOC2"
  soc2_enabled     = false
  pci_dss_enabled  = false
  hipaa_enabled    = false
  gdpr_enabled     = false
  report_frequency = "monthly"
}
