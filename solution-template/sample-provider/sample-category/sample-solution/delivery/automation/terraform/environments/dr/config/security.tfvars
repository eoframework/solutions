#------------------------------------------------------------------------------
# Security Configuration - DR Environment
#------------------------------------------------------------------------------
# DR security settings. Same controls as production for compliance.
# Security is critical in DR to prevent unauthorized access during failover.
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Network Access Controls
#------------------------------------------------------------------------------

# CIDR blocks allowed HTTPS/HTTP access to ALB
allowed_https_cidrs = ["0.0.0.0/0"]
allowed_http_cidrs  = ["0.0.0.0/0"]

# SSH access (DR: disabled for security)
enable_ssh_access  = false
allowed_ssh_cidrs  = []               # Empty = no SSH access

#------------------------------------------------------------------------------
# Instance Security
#------------------------------------------------------------------------------

# IAM Instance Profile
enable_instance_profile = true

# SSM Session Manager (preferred over SSH)
enable_ssm_access = true

# Instance Metadata Service v2 (required for security)
require_imdsv2     = true
metadata_hop_limit = 1

#------------------------------------------------------------------------------
# Encryption
#------------------------------------------------------------------------------

enable_kms_encryption = true          # DR: Always enabled
