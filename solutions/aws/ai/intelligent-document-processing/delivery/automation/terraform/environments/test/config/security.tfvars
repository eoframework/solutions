#------------------------------------------------------------------------------
# Security Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-02 11:21:17
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

auth = {
  advanced_security_mode = "OFF"  # Advanced security mode
  auto_verified_attributes = ["email"]  # Auto-verified attributes
  callback_urls = []  # OAuth callback URLs
  domain = ""  # Cognito domain prefix
  enabled = true  # Enable Cognito authentication
  logout_urls = []  # OAuth logout URLs
  mfa_configuration = "OFF"  # MFA configuration
  password_minimum_length = 8  # Minimum password length
  password_require_lowercase = true  # Require lowercase
  password_require_numbers = true  # Require numbers
  password_require_symbols = false  # Require symbols
  password_require_uppercase = true  # Require uppercase
  username_attributes = ["email"]  # Username attributes
}

security = {
  enable_kms_key_rotation = true  # Enable KMS key rotation
  kms_deletion_window_days = 7  # KMS key deletion window (days)
}
