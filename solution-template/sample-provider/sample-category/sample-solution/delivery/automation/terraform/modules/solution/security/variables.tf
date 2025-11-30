# Solution Security Module - Variables
# Accepts grouped object variables from environment configuration

#------------------------------------------------------------------------------
# Context from Core Module
#------------------------------------------------------------------------------

variable "name_prefix" {
  description = "Name prefix for resources (from core module)"
  type        = string
}

variable "common_tags" {
  description = "Common tags for resources (from core module)"
  type        = map(string)
}

variable "alb_arn" {
  description = "ALB ARN for WAF association (from core module)"
  type        = string
  default     = ""
}

#------------------------------------------------------------------------------
# Security Configuration (from security.tfvars)
#------------------------------------------------------------------------------

variable "security" {
  description = "Security and access control configuration"
  type = object({
    # Network Access Controls
    allowed_https_cidrs       = list(string)
    allowed_http_cidrs        = list(string)
    allowed_ssh_cidrs         = list(string)
    enable_ssh_access         = bool
    # Instance Security
    enable_instance_profile   = bool
    enable_ssm_access         = bool
    require_imdsv2            = bool
    metadata_hop_limit        = number
    # KMS Encryption
    enable_kms_encryption     = bool
    kms_deletion_window       = number
    enable_key_rotation       = bool
    # WAF Configuration
    enable_waf                = bool
    waf_rate_limit            = number
    waf_ip_address_version    = optional(string, "IPV4")
    waf_rule_priorities       = optional(map(number), {})
    # GuardDuty Configuration
    enable_guardduty               = bool
    guardduty_finding_frequency    = optional(string, "FIFTEEN_MINUTES")
    guardduty_s3_protection        = optional(bool, true)
    guardduty_eks_protection       = optional(bool, false)
    guardduty_malware_protection   = optional(bool, false)
    guardduty_severity_threshold   = optional(number, 7)
    # CloudTrail Configuration
    enable_cloudtrail                    = bool
    cloudtrail_retention_days            = number
    cloudtrail_include_global_events     = optional(bool, true)
    cloudtrail_is_multi_region           = optional(bool, true)
    cloudtrail_enable_log_validation     = optional(bool, true)
    cloudtrail_event_read_write_type     = optional(string, "All")
    cloudtrail_include_management_events = optional(bool, true)
    # S3 Security Defaults
    s3_block_public_acls       = optional(bool, true)
    s3_block_public_policy     = optional(bool, true)
    s3_ignore_public_acls      = optional(bool, true)
    s3_restrict_public_buckets = optional(bool, true)
    s3_noncurrent_version_days = optional(number, 30)
    s3_encryption_algorithm    = optional(string, "aws:kms")
    # Service Ports
    db_port                   = number
    cache_port                = number
  })
}

#------------------------------------------------------------------------------
# Optional WAF Configuration (not typically in tfvars)
#------------------------------------------------------------------------------

variable "waf_blocked_ips" {
  description = "List of IP addresses to block (CIDR notation)"
  type        = list(string)
  default     = []
}

variable "waf_blocked_countries" {
  description = "List of country codes to block (ISO 3166-1 alpha-2)"
  type        = list(string)
  default     = []
}
