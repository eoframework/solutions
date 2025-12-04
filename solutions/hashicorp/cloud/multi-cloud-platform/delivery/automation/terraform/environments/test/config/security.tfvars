#------------------------------------------------------------------------------
# Security Configuration
# Generated from configuration.csv - Test values
#------------------------------------------------------------------------------

security = {
  # KMS Encryption
  enable_kms_encryption     = true
  kms_deletion_window       = 7

  # WAF Configuration
  enable_waf                = false
  waf_rate_limit            = 10000

  # GuardDuty Configuration
  enable_guardduty          = false

  # CloudTrail Configuration
  enable_cloudtrail         = false
  cloudtrail_retention_days = 30

  # Authentication
  sso_enabled               = true
  mfa_required              = true
}
