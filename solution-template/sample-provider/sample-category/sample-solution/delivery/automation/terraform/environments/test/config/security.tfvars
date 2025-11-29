#------------------------------------------------------------------------------
# Security Configuration - TEST Environment
#------------------------------------------------------------------------------

allowed_https_cidrs = ["0.0.0.0/0"]
allowed_http_cidrs  = ["0.0.0.0/0"]

enable_ssh_access  = true             # Test: enabled for debugging
allowed_ssh_cidrs  = []

enable_instance_profile = true
enable_ssm_access = true

require_imdsv2     = true
metadata_hop_limit = 1

enable_kms_encryption = false         # Test: disabled for cost savings
