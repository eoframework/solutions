#------------------------------------------------------------------------------
# Security Configuration
# Generated from configuration.csv - DR values
#------------------------------------------------------------------------------

security = {
  # KMS Encryption
  enable_kms_encryption     = true
  kms_deletion_window       = 30

  # WAF Configuration (managed at prod)
  enable_waf                = false
  waf_rate_limit            = 2000

  # GuardDuty Configuration
  enable_guardduty          = true

  # CloudTrail Configuration (managed at prod)
  enable_cloudtrail         = false
  cloudtrail_retention_days = 365

  # Authentication
  sso_enabled               = true
  mfa_required              = true
}
