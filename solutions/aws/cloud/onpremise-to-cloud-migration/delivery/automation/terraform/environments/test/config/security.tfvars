#------------------------------------------------------------------------------
# Security Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 17:52:48
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

security = {
  enable_config = false  # Enable AWS Config
  enable_guard_duty = false  # Enable GuardDuty
  enable_kms_key_rotation = true  # Enable KMS key rotation
  enable_security_hub = false  # Enable Security Hub
  enable_waf = false  # Enable WAF for ALB
  kms_deletion_window_days = 7  # KMS key deletion window
  waf_rate_limit = 2000  # WAF rate limit per IP
}
