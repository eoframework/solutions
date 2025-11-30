#------------------------------------------------------------------------------
# Security Configuration
#------------------------------------------------------------------------------
# Security settings including access controls, encryption, and instance security.
# These values are typically derived from the delivery configuration.csv
# under the "Security" or "Access Control" sections.
#------------------------------------------------------------------------------

security = {
  #----------------------------------------------------------------------------
  # Network Access Controls
  #----------------------------------------------------------------------------
  # CIDR blocks allowed HTTPS/HTTP access to ALB
  allowed_https_cidrs = ["0.0.0.0/0"]
  allowed_http_cidrs  = ["0.0.0.0/0"]

  # SSH access (Production: typically restricted or disabled)
  enable_ssh_access = false
  allowed_ssh_cidrs = []           # Empty = no SSH access

  #----------------------------------------------------------------------------
  # Instance Security
  #----------------------------------------------------------------------------
  # IAM Instance Profile
  enable_instance_profile = true

  # SSM Session Manager (preferred over SSH)
  enable_ssm_access = true

  # Instance Metadata Service v2 (required for security)
  require_imdsv2     = true
  metadata_hop_limit = 1

  #----------------------------------------------------------------------------
  # Encryption
  #----------------------------------------------------------------------------
  enable_kms_encryption = true      # Production: always enabled
  kms_deletion_window   = 30
  enable_key_rotation   = true

  #----------------------------------------------------------------------------
  # AWS Security Services
  #----------------------------------------------------------------------------
  enable_waf                = true
  waf_rate_limit            = 2000
  enable_guardduty          = true
  enable_cloudtrail         = true
  cloudtrail_retention_days = 365
}
