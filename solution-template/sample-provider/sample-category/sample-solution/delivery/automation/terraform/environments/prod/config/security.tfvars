#------------------------------------------------------------------------------
# Security Configuration - WAF, GuardDuty, KMS, CloudTrail - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-11-30 15:48:19
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

security = {
  allowed_http_cidrs = ["0.0.0.0/0"]  # CIDR blocks allowed HTTP access
  allowed_https_cidrs = ["0.0.0.0/0"]  # CIDR blocks allowed HTTPS access
  allowed_ssh_cidrs = []  # CIDR blocks allowed SSH access
  cache_port = 6379  # Cache port number
  cloudtrail_enable_log_validation = true  # Enable log file validation
  # Event types to log (All/ReadOnly/WriteOnly)
  cloudtrail_event_read_write_type = "All"
  cloudtrail_include_global_events = true  # Include global service events
  cloudtrail_include_management_events = true  # Include management events
  cloudtrail_is_multi_region = true  # Enable multi-region trail
  cloudtrail_retention_days = 365  # CloudTrail log retention (days)
  db_port = 5432  # Database port number
  enable_cloudtrail = true  # Enable CloudTrail API logging
  # Enable Amazon GuardDuty threat detection
  enable_guardduty = true
  enable_instance_profile = true  # Enable IAM instance profile
  enable_key_rotation = true  # Enable automatic KMS key rotation
  enable_kms_encryption = true  # Enable KMS encryption for resources
  enable_ssh_access = false  # Enable SSH access to instances
  enable_ssm_access = true  # Enable SSM Session Manager access
  enable_waf = true  # Enable AWS WAF on ALB
  guardduty_eks_protection = false  # Enable GuardDuty EKS protection
  guardduty_finding_frequency = "FIFTEEN_MINUTES"  # GuardDuty finding publishing frequency
  guardduty_malware_protection = true  # Enable GuardDuty malware protection
  guardduty_s3_protection = true  # Enable GuardDuty S3 protection
  # GuardDuty alert severity threshold (1-10)
  guardduty_severity_threshold = 7
  kms_deletion_window = 30  # KMS key deletion window (days)
  metadata_hop_limit = 1  # IMDS hop limit
  require_imdsv2 = true  # Require Instance Metadata Service v2
  s3_block_public_acls = true  # Block public ACLs on S3 buckets
  s3_block_public_policy = true  # Block public policies on S3 buckets
  s3_encryption_algorithm = "aws:kms"  # S3 server-side encryption algorithm
  s3_ignore_public_acls = true  # Ignore public ACLs on S3 buckets
  s3_noncurrent_version_days = 30  # S3 noncurrent version retention (days)
  s3_restrict_public_buckets = true  # Restrict public bucket policies
  waf_ip_address_version = "IPV4"  # WAF IP address version (IPV4/IPV6)
  waf_rate_limit = 2000  # WAF rate limit per IP (5-min window)
  waf_rule_priorities = { rate_limit = 1, blocked_ip = 2, geo_block = 3, common_rules = 10, sqli = 20, bad_inputs = 30 }  # WAF rule priority mappings
}
