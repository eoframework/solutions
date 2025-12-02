#------------------------------------------------------------------------------
# IDP DR Vault Module
#------------------------------------------------------------------------------
# Creates infrastructure in DR region to receive replicated data:
# - S3 bucket for document replication (CRR destination)
# - Backup vault for DynamoDB backup copies
# - KMS key for DR encryption
# - IAM roles for restore operations
#
# This module runs in the DR REGION via aws.dr provider
#------------------------------------------------------------------------------

locals {
  name_prefix = "${var.project.name}-${var.project.environment}"
}

#------------------------------------------------------------------------------
# KMS Key for DR Region Encryption
#------------------------------------------------------------------------------

resource "aws_kms_key" "dr" {
  count = var.dr.vault_enabled ? 1 : 0

  description             = "${local.name_prefix} DR encryption key"
  deletion_window_in_days = var.dr.vault_kms_deletion_window_days
  enable_key_rotation     = true

  # Allow cross-region operations
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EnableRootAccess"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "AllowS3Replication"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:GenerateDataKey*"
        ]
        Resource = "*"
      },
      {
        Sid    = "AllowBackupService"
        Effect = "Allow"
        Principal = {
          Service = "backup.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey*",
          "kms:DescribeKey",
          "kms:CreateGrant"
        ]
        Resource = "*"
      }
    ]
  })

  tags = merge(var.common_tags, {
    Purpose = "DR-Encryption"
  })
}

resource "aws_kms_alias" "dr" {
  count = var.dr.vault_enabled ? 1 : 0

  name          = "alias/${local.name_prefix}-dr"
  target_key_id = aws_kms_key.dr[0].key_id
}

#------------------------------------------------------------------------------
# Data Sources
#------------------------------------------------------------------------------

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

#------------------------------------------------------------------------------
# DR S3 Bucket (Replication Destination)
#------------------------------------------------------------------------------

resource "aws_s3_bucket" "dr_documents" {
  count = var.dr.vault_enabled ? 1 : 0

  bucket = "${local.name_prefix}-documents-dr-${data.aws_caller_identity.current.account_id}"

  tags = merge(var.common_tags, {
    Name    = "${local.name_prefix}-documents-dr"
    Purpose = "DR-Replication-Destination"
  })
}

# Versioning (required for replication destination)
resource "aws_s3_bucket_versioning" "dr_documents" {
  count = var.dr.vault_enabled ? 1 : 0

  bucket = aws_s3_bucket.dr_documents[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

# Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "dr_documents" {
  count = var.dr.vault_enabled ? 1 : 0

  bucket = aws_s3_bucket.dr_documents[0].id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.dr[0].arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

# Block public access
resource "aws_s3_bucket_public_access_block" "dr_documents" {
  count = var.dr.vault_enabled ? 1 : 0

  bucket = aws_s3_bucket.dr_documents[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Lifecycle rules for DR bucket
resource "aws_s3_bucket_lifecycle_configuration" "dr_documents" {
  count = var.dr.vault_enabled ? 1 : 0

  bucket = aws_s3_bucket.dr_documents[0].id

  rule {
    id     = "dr-lifecycle"
    status = "Enabled"

    # Transition to cheaper storage after some time (DR data is rarely accessed)
    transition {
      days          = var.dr.vault_transition_to_ia_days
      storage_class = "STANDARD_IA"
    }

    # Keep noncurrent versions for recovery
    noncurrent_version_expiration {
      noncurrent_days = var.dr.vault_noncurrent_version_expiration_days
    }
  }
}

#------------------------------------------------------------------------------
# DR Backup Vault (Receives DynamoDB backup copies)
#------------------------------------------------------------------------------

resource "aws_backup_vault" "dr" {
  count = var.dr.vault_enabled ? 1 : 0

  name        = "${local.name_prefix}-dr-vault"
  kms_key_arn = aws_kms_key.dr[0].arn

  tags = merge(var.common_tags, {
    Purpose = "DR-Destination"
  })
}

#------------------------------------------------------------------------------
# Vault Lock (Optional - for compliance/immutable backups)
#------------------------------------------------------------------------------

resource "aws_backup_vault_lock_configuration" "dr" {
  count = var.dr.vault_enabled && var.dr.vault_enable_lock ? 1 : 0

  backup_vault_name = aws_backup_vault.dr[0].name
}

#------------------------------------------------------------------------------
# IAM Role for Restore Operations
#------------------------------------------------------------------------------

resource "aws_iam_role" "restore" {
  count = var.dr.vault_enabled ? 1 : 0

  name = "${local.name_prefix}-dr-restore-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "backup.amazonaws.com"
        }
      }
    ]
  })

  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "restore" {
  count = var.dr.vault_enabled ? 1 : 0

  role       = aws_iam_role.restore[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
}

# Additional policy for DynamoDB restore
resource "aws_iam_role_policy" "restore_dynamodb" {
  count = var.dr.vault_enabled ? 1 : 0

  name = "${local.name_prefix}-dr-restore-dynamodb"
  role = aws_iam_role.restore[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DynamoDBRestore"
        Effect = "Allow"
        Action = [
          "dynamodb:RestoreTableFromBackup",
          "dynamodb:RestoreTableToPointInTime",
          "dynamodb:CreateTable",
          "dynamodb:DescribeTable",
          "dynamodb:UpdateTable",
          "dynamodb:UpdateContinuousBackups",
          "dynamodb:TagResource"
        ]
        Resource = "*"
      },
      {
        Sid    = "KMSAccess"
        Effect = "Allow"
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey",
          "kms:CreateGrant"
        ]
        Resource = aws_kms_key.dr[0].arn
      }
    ]
  })
}

# Policy for S3 restore
resource "aws_iam_role_policy" "restore_s3" {
  count = var.dr.vault_enabled ? 1 : 0

  name = "${local.name_prefix}-dr-restore-s3"
  role = aws_iam_role.restore[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3Access"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = [
          aws_s3_bucket.dr_documents[0].arn,
          "${aws_s3_bucket.dr_documents[0].arn}/*"
        ]
      }
    ]
  })
}

#------------------------------------------------------------------------------
# SNS Topic for DR Notifications
#------------------------------------------------------------------------------

resource "aws_sns_topic" "dr_notifications" {
  count = var.dr.vault_enabled ? 1 : 0

  name              = "${local.name_prefix}-dr-notifications"
  kms_master_key_id = aws_kms_key.dr[0].id

  tags = var.common_tags
}

resource "aws_backup_vault_notifications" "dr" {
  count = var.dr.vault_enabled ? 1 : 0

  backup_vault_name   = aws_backup_vault.dr[0].name
  sns_topic_arn       = aws_sns_topic.dr_notifications[0].arn
  backup_vault_events = [
    "COPY_JOB_STARTED",
    "COPY_JOB_SUCCESSFUL",
    "COPY_JOB_FAILED",
    "RESTORE_JOB_STARTED",
    "RESTORE_JOB_COMPLETED",
    "RESTORE_JOB_FAILED"
  ]
}
