#------------------------------------------------------------------------------
# AWS CloudTrail Module (Provider-Level Primitive)
#------------------------------------------------------------------------------
# Reusable CloudTrail with S3 bucket and lifecycle configuration
#------------------------------------------------------------------------------

data "aws_caller_identity" "current" {}

#------------------------------------------------------------------------------
# CloudTrail S3 Bucket
#------------------------------------------------------------------------------
resource "aws_s3_bucket" "cloudtrail" {
  bucket = "${var.name_prefix}-cloudtrail-${data.aws_caller_identity.current.account_id}"

  tags = var.common_tags
}

resource "aws_s3_bucket_policy" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSCloudTrailAclCheck"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.cloudtrail.arn
      },
      {
        Sid    = "AWSCloudTrailWrite"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.cloudtrail.arn}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

resource "aws_s3_bucket_lifecycle_configuration" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id

  rule {
    id     = "expire-old-logs"
    status = "Enabled"

    filter {
      prefix = ""
    }

    expiration {
      days = var.retention_days
    }

    transition {
      days          = var.transition_to_glacier_days
      storage_class = "GLACIER"
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail" {
  count = var.kms_key_arn != "" ? 1 : 0

  bucket = aws_s3_bucket.cloudtrail.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_key_arn
      sse_algorithm     = "aws:kms"
    }
  }
}

#------------------------------------------------------------------------------
# CloudTrail
#------------------------------------------------------------------------------
resource "aws_cloudtrail" "main" {
  name                          = "${var.name_prefix}-trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail.id
  include_global_service_events = var.include_global_service_events
  is_multi_region_trail         = var.is_multi_region_trail
  enable_logging                = true
  kms_key_id                    = var.kms_key_arn != "" ? var.kms_key_arn : null

  event_selector {
    read_write_type           = "All"
    include_management_events = true
  }

  tags = var.common_tags

  depends_on = [aws_s3_bucket_policy.cloudtrail]
}
