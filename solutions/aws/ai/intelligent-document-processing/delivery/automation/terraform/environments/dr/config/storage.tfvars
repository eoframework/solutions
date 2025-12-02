#------------------------------------------------------------------------------
# Storage Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-02 11:50:18
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

storage = {
  cors_allowed_origins = ["*"]  # CORS allowed origins
  create_output_bucket = true  # Create output bucket
  document_expiration_days = 365  # Document expiration (days)
  enable_direct_upload = true  # Enable direct S3 upload
  force_destroy = false  # Allow S3 bucket destruction
  noncurrent_version_expiration_days = 30  # Noncurrent version expiration
  output_expiration_days = 30  # Output expiration (days)
  transition_to_glacier_days = 90  # Transition to Glacier (days)
  transition_to_ia_days = 30  # Transition to S3-IA (days)
  versioning_enabled = true  # Enable S3 versioning
}
