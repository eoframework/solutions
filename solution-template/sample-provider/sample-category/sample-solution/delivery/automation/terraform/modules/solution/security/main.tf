# Solution Security Module
# Deploys: WAF, GuardDuty, CloudTrail, KMS key

locals {
  name_prefix = var.name_prefix
  common_tags = var.common_tags
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

#------------------------------------------------------------------------------
# KMS Key for Encryption
#------------------------------------------------------------------------------

module "kms" {
  source = "../../aws/kms"
  count  = var.security.enable_kms_encryption ? 1 : 0

  name_prefix             = local.name_prefix
  tags                    = local.common_tags
  deletion_window_in_days = var.security.kms_deletion_window
  enable_key_rotation     = var.security.enable_key_rotation
}

#------------------------------------------------------------------------------
# AWS WAF v2 (Web ACL only - association done in INTEGRATIONS section)
#------------------------------------------------------------------------------

module "waf" {
  source = "../../aws/waf"
  count  = var.security.enable_waf ? 1 : 0

  name_prefix = local.name_prefix
  tags        = local.common_tags
  rate_limit  = var.security.waf_rate_limit
  # NOTE: resource_arn intentionally not passed here to avoid circular dependency
  # WAF to ALB association is done in environment main.tf INTEGRATIONS section
}

#------------------------------------------------------------------------------
# AWS GuardDuty
#------------------------------------------------------------------------------

resource "aws_guardduty_detector" "main" {
  count = var.security.enable_guardduty ? 1 : 0

  enable                       = true
  finding_publishing_frequency = var.security.guardduty_finding_frequency

  tags = local.common_tags
}

#------------------------------------------------------------------------------
# GuardDuty Detector Features (replaces deprecated datasources block)
#------------------------------------------------------------------------------

resource "aws_guardduty_detector_feature" "s3_data_events" {
  count       = var.security.enable_guardduty ? 1 : 0
  detector_id = aws_guardduty_detector.main[0].id
  name        = "S3_DATA_EVENTS"
  status      = var.security.guardduty_s3_protection ? "ENABLED" : "DISABLED"
}

resource "aws_guardduty_detector_feature" "eks_audit_logs" {
  count       = var.security.enable_guardduty ? 1 : 0
  detector_id = aws_guardduty_detector.main[0].id
  name        = "EKS_AUDIT_LOGS"
  status      = var.security.guardduty_eks_protection ? "ENABLED" : "DISABLED"
}

resource "aws_guardduty_detector_feature" "ebs_malware_protection" {
  count       = var.security.enable_guardduty ? 1 : 0
  detector_id = aws_guardduty_detector.main[0].id
  name        = "EBS_MALWARE_PROTECTION"
  status      = var.security.guardduty_malware_protection ? "ENABLED" : "DISABLED"
}

#------------------------------------------------------------------------------
# AWS CloudTrail
#------------------------------------------------------------------------------

resource "aws_cloudtrail" "main" {
  count = var.security.enable_cloudtrail ? 1 : 0

  name                          = "${local.name_prefix}-trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail[0].id
  include_global_service_events = var.security.cloudtrail_include_global_events
  is_multi_region_trail         = var.security.cloudtrail_is_multi_region
  enable_log_file_validation    = var.security.cloudtrail_enable_log_validation
  kms_key_id                    = var.security.enable_kms_encryption ? module.kms[0].key_arn : null

  event_selector {
    read_write_type           = var.security.cloudtrail_event_read_write_type
    include_management_events = var.security.cloudtrail_include_management_events
  }

  tags = local.common_tags

  depends_on = [aws_s3_bucket_policy.cloudtrail]
}

resource "aws_s3_bucket" "cloudtrail" {
  count  = var.security.enable_cloudtrail ? 1 : 0
  bucket = "${local.name_prefix}-cloudtrail-${data.aws_caller_identity.current.account_id}"

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-cloudtrail" })
}

resource "aws_s3_bucket_versioning" "cloudtrail" {
  count  = var.security.enable_cloudtrail ? 1 : 0
  bucket = aws_s3_bucket.cloudtrail[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail" {
  count  = var.security.enable_cloudtrail ? 1 : 0
  bucket = aws_s3_bucket.cloudtrail[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.security.enable_kms_encryption ? var.security.s3_encryption_algorithm : "AES256"
      kms_master_key_id = var.security.enable_kms_encryption ? module.kms[0].key_arn : null
    }
  }
}

resource "aws_s3_bucket_public_access_block" "cloudtrail" {
  count  = var.security.enable_cloudtrail ? 1 : 0
  bucket = aws_s3_bucket.cloudtrail[0].id

  block_public_acls       = var.security.s3_block_public_acls
  block_public_policy     = var.security.s3_block_public_policy
  ignore_public_acls      = var.security.s3_ignore_public_acls
  restrict_public_buckets = var.security.s3_restrict_public_buckets
}

resource "aws_s3_bucket_lifecycle_configuration" "cloudtrail" {
  count  = var.security.enable_cloudtrail ? 1 : 0
  bucket = aws_s3_bucket.cloudtrail[0].id

  rule {
    id     = "cloudtrail-retention"
    status = "Enabled"

    expiration {
      days = var.security.cloudtrail_retention_days
    }

    noncurrent_version_expiration {
      noncurrent_days = var.security.s3_noncurrent_version_days
    }
  }
}

resource "aws_s3_bucket_policy" "cloudtrail" {
  count  = var.security.enable_cloudtrail ? 1 : 0
  bucket = aws_s3_bucket.cloudtrail[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AWSCloudTrailAclCheck"
        Effect    = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action    = "s3:GetBucketAcl"
        Resource  = aws_s3_bucket.cloudtrail[0].arn
      },
      {
        Sid       = "AWSCloudTrailWrite"
        Effect    = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action    = "s3:PutObject"
        Resource  = "${aws_s3_bucket.cloudtrail[0].arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
        Condition = { StringEquals = { "s3:x-amz-acl" = "bucket-owner-full-control" } }
      }
    ]
  })
}
