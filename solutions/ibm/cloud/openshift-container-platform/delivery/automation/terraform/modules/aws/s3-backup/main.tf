#------------------------------------------------------------------------------
# AWS S3 Backup Module for OpenShift
#------------------------------------------------------------------------------
# Creates S3 bucket for etcd and configuration backups with lifecycle policies
# Note: Cross-region replication should be configured separately via DR module
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# S3 Bucket for Backups
#------------------------------------------------------------------------------
resource "aws_s3_bucket" "backup" {
  bucket = var.bucket_name

  tags = merge(var.common_tags, {
    Name    = var.bucket_name
    Purpose = "OpenShift cluster backups"
  })
}

resource "aws_s3_bucket_versioning" "backup" {
  bucket = aws_s3_bucket.backup.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "backup" {
  bucket = aws_s3_bucket.backup.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.kms_key_arn != null ? "aws:kms" : "AES256"
      kms_master_key_id = var.kms_key_arn
    }
    bucket_key_enabled = var.kms_key_arn != null
  }
}

resource "aws_s3_bucket_public_access_block" "backup" {
  bucket = aws_s3_bucket.backup.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "backup" {
  bucket = aws_s3_bucket.backup.id

  rule {
    id     = "etcd-backup-lifecycle"
    status = "Enabled"

    filter {
      prefix = "etcd/"
    }

    expiration {
      days = var.etcd_retention_days
    }

    noncurrent_version_expiration {
      noncurrent_days = 7
    }
  }

  rule {
    id     = "config-backup-lifecycle"
    status = "Enabled"

    filter {
      prefix = "config/"
    }

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    expiration {
      days = var.config_retention_days
    }

    noncurrent_version_expiration {
      noncurrent_days = 7
    }
  }

  rule {
    id     = "logs-lifecycle"
    status = "Enabled"

    filter {
      prefix = "logs/"
    }

    transition {
      days          = 7
      storage_class = "GLACIER"
    }

    expiration {
      days = var.log_retention_days
    }
  }
}
