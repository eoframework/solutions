#------------------------------------------------------------------------------
# Security Configuration - DR Environment
#------------------------------------------------------------------------------
# DR DIFFERENCES:
# - WAF: DISABLED (managed at production site)
# - GuardDuty: DISABLED (managed at production site)
# - KMS: Enabled (DR needs its own KMS key)
# - CloudTrail: Enabled (audit trail in DR region)
#------------------------------------------------------------------------------

security = {
  # Network Access Controls
  allowed_http_cidrs  = ["0.0.0.0/0"]
  allowed_https_cidrs = ["0.0.0.0/0"]
  allowed_ssh_cidrs   = []
  enable_ssh_access   = false

  # Instance Security
  enable_instance_profile = true
  enable_ssm_access       = true
  require_imdsv2          = true
  metadata_hop_limit      = 1

  # KMS Encryption (ENABLED for DR)
  enable_kms_encryption = true
  kms_deletion_window   = 30
  enable_key_rotation   = true

  # WAF (DISABLED for DR - managed at production)
  enable_waf             = false
  waf_rate_limit         = 2000
  waf_ip_address_version = "IPV4"
  waf_rule_priorities    = {}

  # GuardDuty (DISABLED for DR - managed at production)
  enable_guardduty               = false
  guardduty_finding_frequency    = "FIFTEEN_MINUTES"
  guardduty_s3_protection        = false
  guardduty_eks_protection       = false
  guardduty_malware_protection   = false
  guardduty_severity_threshold   = 7

  # CloudTrail (ENABLED for DR audit trail)
  enable_cloudtrail                    = true
  cloudtrail_retention_days            = 365
  cloudtrail_include_global_events     = true
  cloudtrail_is_multi_region           = true
  cloudtrail_enable_log_validation     = true
  cloudtrail_event_read_write_type     = "All"
  cloudtrail_include_management_events = true

  # S3 Security
  s3_block_public_acls       = true
  s3_block_public_policy     = true
  s3_ignore_public_acls      = true
  s3_restrict_public_buckets = true
  s3_noncurrent_version_days = 30
  s3_encryption_algorithm    = "aws:kms"

  # Service Ports
  db_port    = 5432
  cache_port = 6379
}
