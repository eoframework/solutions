#------------------------------------------------------------------------------
# Encryption Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 22:21:02
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

kms = {
  key_algorithm = "GOOGLE_SYMMETRIC_ENCRYPTION"  # Key algorithm
  key_count = 6  # Number of encryption keys
  key_rotation_days = 90  # Automatic key rotation period (days)
  keyring_location = "us"  # Key ring location
  keyring_name = "landing-zone-keyring-prod"  # Cloud KMS key ring name
  protection_level = "SOFTWARE"  # Key protection level
}
