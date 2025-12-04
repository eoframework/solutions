#------------------------------------------------------------------------------
# Storage Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 17:57:13
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

storage = {
  enable_replication_time_control = false  # Enable S3 RTC (15-min SLA)
  enable_versioning = true  # Enable S3 versioning
  noncurrent_version_expiration_days = 7  # Days to keep old versions
  # S3 replication latency alarm threshold (seconds)
  replication_latency_threshold = 0
  transition_to_glacier_days = 180  # Days before Glacier transition
  transition_to_ia_days = 90  # Days before IA transition
}
