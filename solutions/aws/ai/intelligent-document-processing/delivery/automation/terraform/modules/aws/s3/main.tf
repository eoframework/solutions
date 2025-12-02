#------------------------------------------------------------------------------
# AWS S3 Bucket Module
#------------------------------------------------------------------------------
# Creates S3 buckets for document storage with:
# - Versioning, lifecycle policies
# - KMS encryption
# - Lambda triggers for document processing
# - CORS configuration for web uploads
#------------------------------------------------------------------------------

resource "aws_s3_bucket" "this" {
  bucket        = var.bucket_name
  force_destroy = var.force_destroy

  tags = merge(var.common_tags, {
    Name = var.bucket_name
  })
}

#------------------------------------------------------------------------------
# Versioning
#------------------------------------------------------------------------------

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = var.versioning_enabled ? "Enabled" : "Suspended"
  }
}

#------------------------------------------------------------------------------
# Server-Side Encryption
#------------------------------------------------------------------------------

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.kms_key_arn != null ? "aws:kms" : "AES256"
      kms_master_key_id = var.kms_key_arn
    }
    bucket_key_enabled = var.kms_key_arn != null
  }
}

#------------------------------------------------------------------------------
# Public Access Block
#------------------------------------------------------------------------------

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

#------------------------------------------------------------------------------
# Lifecycle Rules
#------------------------------------------------------------------------------

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count  = length(var.lifecycle_rules) > 0 ? 1 : 0
  bucket = aws_s3_bucket.this.id

  dynamic "rule" {
    for_each = var.lifecycle_rules
    content {
      id     = rule.value.id
      status = lookup(rule.value, "enabled", true) ? "Enabled" : "Disabled"

      filter {
        prefix = lookup(rule.value, "prefix", "")
      }

      # Transition to Infrequent Access
      dynamic "transition" {
        for_each = lookup(rule.value, "transition_ia_days", null) != null ? [1] : []
        content {
          days          = rule.value.transition_ia_days
          storage_class = "STANDARD_IA"
        }
      }

      # Transition to Glacier
      dynamic "transition" {
        for_each = lookup(rule.value, "transition_glacier_days", null) != null ? [1] : []
        content {
          days          = rule.value.transition_glacier_days
          storage_class = "GLACIER"
        }
      }

      # Expiration
      dynamic "expiration" {
        for_each = lookup(rule.value, "expiration_days", null) != null ? [1] : []
        content {
          days = rule.value.expiration_days
        }
      }

      # Noncurrent version expiration
      dynamic "noncurrent_version_expiration" {
        for_each = lookup(rule.value, "noncurrent_version_expiration_days", null) != null ? [1] : []
        content {
          noncurrent_days = rule.value.noncurrent_version_expiration_days
        }
      }
    }
  }

  depends_on = [aws_s3_bucket_versioning.this]
}

#------------------------------------------------------------------------------
# CORS Configuration (for web uploads)
#------------------------------------------------------------------------------

resource "aws_s3_bucket_cors_configuration" "this" {
  count  = length(var.cors_rules) > 0 ? 1 : 0
  bucket = aws_s3_bucket.this.id

  dynamic "cors_rule" {
    for_each = var.cors_rules
    content {
      allowed_headers = lookup(cors_rule.value, "allowed_headers", ["*"])
      allowed_methods = cors_rule.value.allowed_methods
      allowed_origins = cors_rule.value.allowed_origins
      expose_headers  = lookup(cors_rule.value, "expose_headers", [])
      max_age_seconds = lookup(cors_rule.value, "max_age_seconds", 3600)
    }
  }
}

#------------------------------------------------------------------------------
# Lambda Notifications (for document processing triggers)
#------------------------------------------------------------------------------

resource "aws_s3_bucket_notification" "this" {
  count  = length(var.lambda_notifications) > 0 ? 1 : 0
  bucket = aws_s3_bucket.this.id

  dynamic "lambda_function" {
    for_each = var.lambda_notifications
    content {
      lambda_function_arn = lambda_function.value.lambda_function_arn
      events              = lambda_function.value.events
      filter_prefix       = lookup(lambda_function.value, "filter_prefix", null)
      filter_suffix       = lookup(lambda_function.value, "filter_suffix", null)
    }
  }

  depends_on = [aws_s3_bucket.this]
}

#------------------------------------------------------------------------------
# Bucket Policy
#------------------------------------------------------------------------------

resource "aws_s3_bucket_policy" "this" {
  count  = var.bucket_policy != null ? 1 : 0
  bucket = aws_s3_bucket.this.id
  policy = var.bucket_policy
}
