#------------------------------------------------------------------------------
# GitHub Advanced Security - Production - Monitoring Configuration
#------------------------------------------------------------------------------
# Generated from configuration.csv - DO NOT EDIT DIRECTLY
# Use eof-tools/automation/scripts/generate-tfvars.py to regenerate
#------------------------------------------------------------------------------

monitoring = {
  audit_log_retention_days  = 365
  metrics_enabled           = true
  security_overview_enabled = true
  alerts_enabled            = true
  dashboard_enabled         = true
  log_level                 = "INFO"
  health_check_interval     = 300
}

compliance = {
  frameworks       = "SOC2,PCI-DSS"
  soc2_enabled     = true
  pci_dss_enabled  = true
  hipaa_enabled    = false
  gdpr_enabled     = true
  report_frequency = "weekly"
}
