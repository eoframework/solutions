#------------------------------------------------------------------------------
# Security Configuration - PRODUCTION Environment
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
  # KMS Encryption
  #----------------------------------------------------------------------------
  enable_kms_encryption = true      # Production: always enabled
  kms_deletion_window   = 30
  enable_key_rotation   = true

  #----------------------------------------------------------------------------
  # WAF Configuration
  #----------------------------------------------------------------------------
  enable_waf             = true
  waf_rate_limit         = 2000
  waf_ip_address_version = "IPV4"   # IPV4 or IPV6
  waf_rule_priorities = {
    rate_limit   = 1
    blocked_ip   = 2
    geo_block    = 3
    common_rules = 10
    sqli         = 20
    bad_inputs   = 30
  }

  #----------------------------------------------------------------------------
  # GuardDuty Configuration
  #----------------------------------------------------------------------------
  enable_guardduty             = true
  guardduty_finding_frequency  = "FIFTEEN_MINUTES"  # FIFTEEN_MINUTES, ONE_HOUR, SIX_HOURS
  guardduty_s3_protection      = true
  guardduty_eks_protection     = false
  guardduty_malware_protection = true
  guardduty_severity_threshold = 7                  # 1-10, alerts on >= threshold

  #----------------------------------------------------------------------------
  # CloudTrail Configuration
  #----------------------------------------------------------------------------
  enable_cloudtrail                = true
  cloudtrail_retention_days        = 365
  cloudtrail_include_global_events = true
  cloudtrail_is_multi_region       = true
  cloudtrail_enable_log_validation = true
  cloudtrail_event_read_write_type = "All"          # All, ReadOnly, WriteOnly
  cloudtrail_include_management_events = true

  #----------------------------------------------------------------------------
  # S3 Security Defaults
  #----------------------------------------------------------------------------
  s3_block_public_acls       = true
  s3_block_public_policy     = true
  s3_ignore_public_acls      = true
  s3_restrict_public_buckets = true
  s3_noncurrent_version_days = 30
  s3_encryption_algorithm    = "aws:kms"            # aws:kms or AES256

  #----------------------------------------------------------------------------
  # Service Ports
  #----------------------------------------------------------------------------
  # Database port (5432=PostgreSQL, 3306=MySQL, 1433=SQLServer, 1521=Oracle)
  db_port = 5432

  # Cache port (6379=Redis, 11211=Memcached)
  cache_port = 6379
}
