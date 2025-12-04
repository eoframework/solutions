#------------------------------------------------------------------------------
# Security Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 17:57:14
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

security = {
  enable_kms_key_rotation = true  # Enable KMS key rotation
  enable_waf = false  # Enable WAF
  kms_deletion_window_days = 30  # KMS key deletion window
  waf_rate_limit = 2000  # WAF rate limit per IP
}
