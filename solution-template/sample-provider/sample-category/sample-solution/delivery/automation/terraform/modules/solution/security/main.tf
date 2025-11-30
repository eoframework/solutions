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
# AWS WAF v2
#------------------------------------------------------------------------------

module "waf" {
  source = "../../aws/waf"
  count  = var.security.enable_waf ? 1 : 0

  name_prefix  = local.name_prefix
  tags         = local.common_tags
  resource_arn = var.alb_arn
  rate_limit   = var.security.waf_rate_limit
}

#------------------------------------------------------------------------------
# AWS GuardDuty
#------------------------------------------------------------------------------

resource "aws_guardduty_detector" "main" {
  count = var.security.enable_guardduty ? 1 : 0

  enable                       = true
  finding_publishing_frequency = "FIFTEEN_MINUTES"

  datasources {
    s3_logs {
      enable = true
    }
    kubernetes {
      audit_logs {
        enable = false
      }
    }
    malware_protection {
      scan_ec2_instance_with_findings {
        ebs_volumes {
          enable = true
        }
      }
    }
  }

  tags = local.common_tags
}

#------------------------------------------------------------------------------
# AWS CloudTrail
#------------------------------------------------------------------------------

resource "aws_cloudtrail" "main" {
  count = var.security.enable_cloudtrail ? 1 : 0

  name                          = "${local.name_prefix}-trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail[0].id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true
  kms_key_id                    = var.security.enable_kms_encryption ? module.kms[0].key_arn : null

  event_selector {
    read_write_type           = "All"
    include_management_events = true
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
      sse_algorithm     = var.security.enable_kms_encryption ? "aws:kms" : "AES256"
      kms_master_key_id = var.security.enable_kms_encryption ? module.kms[0].key_arn : null
    }
  }
}

resource "aws_s3_bucket_public_access_block" "cloudtrail" {
  count  = var.security.enable_cloudtrail ? 1 : 0
  bucket = aws_s3_bucket.cloudtrail[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
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
      noncurrent_days = 30
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
