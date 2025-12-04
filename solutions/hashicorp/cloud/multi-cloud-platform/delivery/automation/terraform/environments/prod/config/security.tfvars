#------------------------------------------------------------------------------
# Security Configuration
# Generated from configuration.csv - Production values
#------------------------------------------------------------------------------

security = {
  # KMS Encryption
  enable_kms_encryption     = true
  kms_deletion_window       = 30

  # WAF Configuration
  enable_waf                = true
  waf_rate_limit            = 2000

  # GuardDuty Configuration
  enable_guardduty          = true

  # CloudTrail Configuration
  enable_cloudtrail         = true
  cloudtrail_retention_days = 365

  # Authentication
  sso_enabled               = true
  mfa_required              = true
}
