#------------------------------------------------------------------------------
# Security Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 23:05:07
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

security = {
  enable_cloudtrail = true  # Enable CloudTrail API logging
  # Enable Amazon GuardDuty threat detection
  enable_guardduty = true
  enable_kms_encryption = true  # Enable KMS encryption for resources
  enable_waf = true  # Enable AWS WAF on ALB
  kms_deletion_window = 30  # KMS key deletion window (days)
  mfa_required = true  # Require multi-factor authentication
  sso_enabled = true  # Enable SSO/SAML authentication
  waf_rate_limit = 2000  # WAF rate limit per IP (5-min window)
}
