#------------------------------------------------------------------------------
# Storage Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 17:52:47
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

storage = {
  enable_replication = true  # Enable cross-region replication
  enable_versioning = true  # Enable S3 versioning
  noncurrent_version_expiration_days = 30  # Days to keep old versions
  # Replication latency alarm threshold (seconds)
  replication_latency_threshold = 900
  transition_to_glacier_days = 90  # Days before Glacier transition
  transition_to_ia_days = 30  # Days before IA transition
}
