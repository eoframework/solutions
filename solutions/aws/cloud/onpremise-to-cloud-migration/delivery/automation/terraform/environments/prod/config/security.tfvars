#------------------------------------------------------------------------------
# Security Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 17:52:47
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

security = {
  enable_config = true  # Enable AWS Config
  enable_guard_duty = true  # Enable GuardDuty
  enable_kms_key_rotation = true  # Enable KMS key rotation
  enable_security_hub = true  # Enable Security Hub
  enable_waf = true  # Enable WAF for ALB
  kms_deletion_window_days = 30  # KMS key deletion window
  waf_rate_limit = 5000  # WAF rate limit per IP
}
