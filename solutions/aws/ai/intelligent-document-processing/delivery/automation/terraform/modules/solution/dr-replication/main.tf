#------------------------------------------------------------------------------
# IDP DR Replication Module
#------------------------------------------------------------------------------
# Creates cross-region replication for IDP serverless architecture:
# - S3 Cross-Region Replication (CRR) for documents
# - DynamoDB Global Tables for metadata/results
# - AWS Backup for DynamoDB (additional protection)
#
# This module runs in PRODUCTION and replicates to DR region.
#------------------------------------------------------------------------------

locals {
  name_prefix = "${var.project.name}-${var.project.environment}"
}

#------------------------------------------------------------------------------
# Data Sources
#------------------------------------------------------------------------------

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

#------------------------------------------------------------------------------
# S3 Cross-Region Replication
#------------------------------------------------------------------------------

# IAM Role for S3 Replication
resource "aws_iam_role" "s3_replication" {
  count = var.dr.enabled ? 1 : 0

  name = "${local.name_prefix}-s3-replication-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.common_tags
}

resource "aws_iam_role_policy" "s3_replication" {
  count = var.dr.enabled ? 1 : 0

  name = "${local.name_prefix}-s3-replication-policy"
  role = aws_iam_role.s3_replication[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "SourceBucketAccess"
        Effect = "Allow"
        Action = [
          "s3:GetReplicationConfiguration",
          "s3:ListBucket"
        ]
        Resource = var.source_bucket_arn
      },
      {
        Sid    = "SourceObjectAccess"
        Effect = "Allow"
        Action = [
          "s3:GetObjectVersionForReplication",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectVersionTagging"
        ]
        Resource = "${var.source_bucket_arn}/*"
      },
      {
        Sid    = "DestinationBucketAccess"
        Effect = "Allow"
        Action = [
          "s3:ReplicateObject",
          "s3:ReplicateDelete",
          "s3:ReplicateTags"
        ]
        Resource = "${var.dr.dr_bucket_arn}/*"
      },
      {
        Sid    = "SourceKMSDecrypt"
        Effect = "Allow"
        Action = [
          "kms:Decrypt"
        ]
        Resource = var.kms_key_arn
        Condition = {
          StringLike = {
            "kms:ViaService"    = "s3.${data.aws_region.current.id}.amazonaws.com"
            "kms:EncryptionContext:aws:s3:arn" = "${var.source_bucket_arn}/*"
          }
        }
      },
      {
        Sid    = "DestinationKMSEncrypt"
        Effect = "Allow"
        Action = [
          "kms:Encrypt"
        ]
        Resource = var.dr.dr_kms_key_arn
        Condition = {
          StringLike = {
            "kms:ViaService"    = "s3.${var.dr.dr_region}.amazonaws.com"
            "kms:EncryptionContext:aws:s3:arn" = "${var.dr.dr_bucket_arn}/*"
          }
        }
      }
    ]
  })
}

# S3 Replication Configuration
resource "aws_s3_bucket_replication_configuration" "documents" {
  count = var.dr.enabled ? 1 : 0

  bucket = var.source_bucket_id
  role   = aws_iam_role.s3_replication[0].arn

  rule {
    id     = "replicate-all-documents"
    status = "Enabled"

    # Replicate all objects
    filter {
      prefix = ""
    }

    # Delete marker replication
    delete_marker_replication {
      status = "Enabled"
    }

    # Destination configuration
    destination {
      bucket        = var.dr.dr_bucket_arn
      storage_class = var.dr.storage_replication_class

      # Encrypt with DR KMS key
      encryption_configuration {
        replica_kms_key_id = var.dr.dr_kms_key_arn
      }

      # Replication time control (for SLA)
      dynamic "replication_time" {
        for_each = var.dr.enable_replication_time_control ? [1] : []
        content {
          status = "Enabled"
          time {
            minutes = 15
          }
        }
      }

      # Metrics for replication monitoring (always enabled for DR)
      metrics {
        status = "Enabled"
        event_threshold {
          minutes = 15
        }
      }
    }

    # Use KMS encryption
    source_selection_criteria {
      sse_kms_encrypted_objects {
        status = "Enabled"
      }
    }
  }

  # Ensure versioning is enabled first
  depends_on = [var.source_bucket_versioning_enabled]
}

#------------------------------------------------------------------------------
# DynamoDB Global Tables
#------------------------------------------------------------------------------
# Note: DynamoDB Global Tables are configured at table creation time.
# The storage module needs to be updated to support replica regions.
# This section provides the IAM role and policy for Global Tables.

resource "aws_iam_role" "dynamodb_replication" {
  count = var.dr.enabled ? 1 : 0

  name = "${local.name_prefix}-dynamodb-replication-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "dynamodb.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.common_tags
}

resource "aws_iam_role_policy" "dynamodb_replication" {
  count = var.dr.enabled ? 1 : 0

  name = "${local.name_prefix}-dynamodb-replication-policy"
  role = aws_iam_role.dynamodb_replication[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DynamoDBReplication"
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:BatchWriteItem",
          "dynamodb:DescribeTable",
          "dynamodb:DescribeStream",
          "dynamodb:GetRecords",
          "dynamodb:GetShardIterator",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = [
          var.results_table_arn,
          "${var.results_table_arn}/stream/*",
          var.jobs_table_arn,
          "${var.jobs_table_arn}/stream/*"
        ]
      },
      {
        Sid    = "KMSAccess"
        Effect = "Allow"
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:DescribeKey"
        ]
        Resource = [
          var.kms_key_arn,
          var.dr.dr_kms_key_arn
        ]
      }
    ]
  })
}

#------------------------------------------------------------------------------
# AWS Backup for DynamoDB (Additional Protection)
#------------------------------------------------------------------------------

resource "aws_backup_vault" "source" {
  count = var.dr.enabled ? 1 : 0

  name        = "${local.name_prefix}-backup-vault"
  kms_key_arn = var.kms_key_arn

  tags = merge(var.common_tags, {
    Purpose = "DR-Source"
  })
}

resource "aws_iam_role" "backup" {
  count = var.dr.enabled ? 1 : 0

  name = "${local.name_prefix}-backup-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "backup.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "backup" {
  count = var.dr.enabled ? 1 : 0

  role       = aws_iam_role.backup[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

resource "aws_iam_role_policy_attachment" "restore" {
  count = var.dr.enabled ? 1 : 0

  role       = aws_iam_role.backup[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
}

# Additional KMS policy for cross-region backup
resource "aws_iam_role_policy" "backup_kms" {
  count = var.dr.enabled ? 1 : 0

  name = "${local.name_prefix}-backup-kms"
  role = aws_iam_role.backup[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
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
        Resource = [
          var.kms_key_arn,
          var.dr.dr_kms_key_arn
        ]
      }
    ]
  })
}

# Backup Plan for DynamoDB
resource "aws_backup_plan" "dynamodb" {
  count = var.dr.enabled ? 1 : 0

  name = "${local.name_prefix}-dynamodb-backup-plan"

  # Daily backup with cross-region copy
  rule {
    rule_name         = "daily-dynamodb-backup"
    target_vault_name = aws_backup_vault.source[0].name
    schedule          = "cron(0 5 * * ? *)"  # Daily at 5 AM UTC

    lifecycle {
      delete_after = var.dr.backup_local_retention_days
    }

    # Cross-region copy to DR
    copy_action {
      destination_vault_arn = var.dr.dr_vault_arn

      lifecycle {
        delete_after = var.dr.backup_retention_days
      }
    }

    # Enable PITR for DynamoDB
    enable_continuous_backup = true
  }

  # Weekly backup with longer retention
  dynamic "rule" {
    for_each = var.dr.enable_weekly_backup ? [1] : []
    content {
      rule_name         = "weekly-dynamodb-backup"
      target_vault_name = aws_backup_vault.source[0].name
      schedule          = "cron(0 5 ? * SUN *)"  # Weekly on Sunday at 5 AM UTC

      lifecycle {
        delete_after = var.dr.weekly_backup_retention_days
      }

      copy_action {
        destination_vault_arn = var.dr.dr_vault_arn

        lifecycle {
          delete_after = var.dr.weekly_backup_retention_days
        }
      }
    }
  }

  tags = var.common_tags
}

# Backup Selection for DynamoDB Tables
resource "aws_backup_selection" "dynamodb" {
  count = var.dr.enabled ? 1 : 0

  name         = "${local.name_prefix}-dynamodb-selection"
  plan_id      = aws_backup_plan.dynamodb[0].id
  iam_role_arn = aws_iam_role.backup[0].arn

  resources = [
    var.results_table_arn,
    var.jobs_table_arn
  ]
}

#------------------------------------------------------------------------------
# SNS Notifications for Backup/Replication Events
#------------------------------------------------------------------------------

resource "aws_backup_vault_notifications" "dr" {
  count = var.dr.enabled && var.sns_topic_arn != null ? 1 : 0

  backup_vault_name   = aws_backup_vault.source[0].name
  sns_topic_arn       = var.sns_topic_arn
  backup_vault_events = [
    "BACKUP_JOB_STARTED",
    "BACKUP_JOB_COMPLETED",
    "BACKUP_JOB_FAILED",
    "COPY_JOB_STARTED",
    "COPY_JOB_SUCCESSFUL",
    "COPY_JOB_FAILED",
    "RESTORE_JOB_STARTED",
    "RESTORE_JOB_COMPLETED",
    "RESTORE_JOB_FAILED"
  ]
}

#------------------------------------------------------------------------------
# CloudWatch Alarms for Replication Monitoring
#------------------------------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "s3_replication_latency" {
  count = var.dr.enabled ? 1 : 0

  alarm_name          = "${local.name_prefix}-s3-replication-latency"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "ReplicationLatency"
  namespace           = "AWS/S3"
  period              = 300
  statistic           = "Maximum"
  threshold           = 900  # 15 minutes
  alarm_description   = "S3 replication latency exceeded threshold"

  dimensions = {
    SourceBucket      = var.source_bucket_id
    DestinationBucket = var.dr.dr_bucket_id
    RuleId            = "replicate-all-documents"
  }

  alarm_actions = var.sns_topic_arn != null ? [var.sns_topic_arn] : []

  tags = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "s3_replication_pending" {
  count = var.dr.enabled ? 1 : 0

  alarm_name          = "${local.name_prefix}-s3-replication-pending"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "BytesPendingReplication"
  namespace           = "AWS/S3"
  period              = 300
  statistic           = "Average"
  threshold           = 104857600  # 100 MB
  alarm_description   = "S3 pending replication bytes exceeded threshold"

  dimensions = {
    SourceBucket      = var.source_bucket_id
    DestinationBucket = var.dr.dr_bucket_id
    RuleId            = "replicate-all-documents"
  }

  alarm_actions = var.sns_topic_arn != null ? [var.sns_topic_arn] : []

  tags = var.common_tags
}
