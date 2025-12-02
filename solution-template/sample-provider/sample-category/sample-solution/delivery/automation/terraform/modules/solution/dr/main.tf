#------------------------------------------------------------------------------
# Consolidated DR Module
#------------------------------------------------------------------------------
# Unified disaster recovery module handling both replication and vault.
#
# Behavior by environment:
# - Production: Creates backup vault + backup plans for cross-region replication
# - Test: Typically disabled (no DR needed for test)
# - DR: Creates destination vault to receive backup copies
#
# Resources created (when enabled):
# - AWS Backup vault (source or destination depending on environment)
# - AWS Backup plan with daily and weekly rules (production only)
# - IAM roles for backup and restore operations
# - Optional vault lock for compliance
# - SNS notifications for backup events
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Data Sources
#------------------------------------------------------------------------------
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  # Determine if this is a DR environment (receives backups vs sends them)
  is_dr_environment = var.environment == "dr"

  # Replication is only enabled in production (sends to DR)
  replication_enabled = var.dr.enabled && var.dr.replication_enabled && !local.is_dr_environment

  # Vault is enabled in DR environment (receives from production)
  vault_enabled = var.dr.enabled && var.dr.vault_enabled && local.is_dr_environment
}

#===============================================================================
# REPLICATION (Production Only) - Sends backups to DR region
#===============================================================================
#------------------------------------------------------------------------------
# IAM Role for AWS Backup
#------------------------------------------------------------------------------
resource "aws_iam_role" "backup" {
  count = local.replication_enabled ? 1 : 0

  name = "${var.name_prefix}-dr-backup-role"

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

resource "aws_iam_role_policy_attachment" "backup" {
  count = local.replication_enabled ? 1 : 0

  role       = aws_iam_role.backup[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

resource "aws_iam_role_policy_attachment" "backup_restore" {
  count = local.replication_enabled ? 1 : 0

  role       = aws_iam_role.backup[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
}

resource "aws_iam_role_policy" "backup_additional" {
  count = local.replication_enabled ? 1 : 0

  name = "${var.name_prefix}-dr-backup-additional"
  role = aws_iam_role.backup[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EC2ImageBackup"
        Effect = "Allow"
        Action = [
          "ec2:CreateImage",
          "ec2:CopyImage",
          "ec2:DeregisterImage",
          "ec2:DescribeImages",
          "ec2:DescribeInstances",
          "ec2:DescribeSnapshots",
          "ec2:DescribeTags",
          "ec2:CreateTags",
          "ec2:DeleteSnapshot"
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
        Resource = [var.kms_key_arn]
      }
    ]
  })
}

#------------------------------------------------------------------------------
# Source Backup Vault (production region)
#------------------------------------------------------------------------------
resource "aws_backup_vault" "source" {
  count = local.replication_enabled ? 1 : 0

  name        = "${var.name_prefix}-backup-vault"
  kms_key_arn = var.kms_key_arn

  tags = merge(var.common_tags, {
    Purpose = "DR-Source"
  })
}

#------------------------------------------------------------------------------
# Backup Plan with Cross-Region Copy
#------------------------------------------------------------------------------
resource "aws_backup_plan" "dr" {
  count = local.replication_enabled ? 1 : 0

  name = "${var.name_prefix}-dr-backup-plan"

  # Daily Backup Rule
  rule {
    rule_name         = "daily-backup-with-dr-copy"
    target_vault_name = aws_backup_vault.source[0].name
    schedule          = "cron(0 5 * * ? *)"

    lifecycle {
      delete_after = var.dr.backup_local_retention_days
    }

    copy_action {
      destination_vault_arn = "arn:aws:backup:${var.dr_region}:${data.aws_caller_identity.current.account_id}:backup-vault:${var.name_prefix}-dr-vault"

      lifecycle {
        delete_after = var.dr.backup_retention_days
      }
    }
  }

  # Weekly Backup Rule (optional)
  dynamic "rule" {
    for_each = var.dr.enable_weekly_backup ? [1] : []

    content {
      rule_name         = "weekly-backup-with-dr-copy"
      target_vault_name = aws_backup_vault.source[0].name
      schedule          = "cron(0 5 ? * SUN *)"

      lifecycle {
        delete_after = var.dr.weekly_backup_retention_days
      }

      copy_action {
        destination_vault_arn = "arn:aws:backup:${var.dr_region}:${data.aws_caller_identity.current.account_id}:backup-vault:${var.name_prefix}-dr-vault"

        lifecycle {
          delete_after = var.dr.weekly_backup_retention_days
        }
      }
    }
  }

  tags = var.common_tags
}

#------------------------------------------------------------------------------
# Backup Selection - Tag-Based
#------------------------------------------------------------------------------
resource "aws_backup_selection" "tag_based" {
  count = local.replication_enabled ? 1 : 0

  name         = "${var.name_prefix}-dr-selection"
  plan_id      = aws_backup_plan.dr[0].id
  iam_role_arn = aws_iam_role.backup[0].arn

  selection_tag {
    type  = "STRINGEQUALS"
    key   = "Backup"
    value = "true"
  }
}

#------------------------------------------------------------------------------
# SNS Notifications for Source Vault
#------------------------------------------------------------------------------
resource "aws_backup_vault_notifications" "source" {
  count = local.replication_enabled && var.sns_topic_arn != "" ? 1 : 0

  backup_vault_name   = aws_backup_vault.source[0].name
  sns_topic_arn       = var.sns_topic_arn
  backup_vault_events = [
    "BACKUP_JOB_STARTED",
    "BACKUP_JOB_COMPLETED",
    "BACKUP_JOB_FAILED",
    "COPY_JOB_STARTED",
    "COPY_JOB_SUCCESSFUL",
    "COPY_JOB_FAILED"
  ]
}

#===============================================================================
# VAULT (DR Environment Only) - Receives backups from production
#===============================================================================
#------------------------------------------------------------------------------
# DR Backup Vault (destination)
#------------------------------------------------------------------------------
resource "aws_backup_vault" "dr" {
  count = local.vault_enabled ? 1 : 0

  name        = "${var.name_prefix}-dr-vault"
  kms_key_arn = var.kms_key_arn

  tags = merge(var.common_tags, {
    Purpose = "DR-Destination"
  })
}

#------------------------------------------------------------------------------
# Vault Lock (Optional - for compliance/immutable backups)
#------------------------------------------------------------------------------
resource "aws_backup_vault_lock_configuration" "dr" {
  count = local.vault_enabled && var.dr.vault_enable_lock ? 1 : 0

  backup_vault_name   = aws_backup_vault.dr[0].name
  changeable_for_days = 3
  min_retention_days  = 7
  max_retention_days  = 365
}

#------------------------------------------------------------------------------
# IAM Role for Restore Operations
#------------------------------------------------------------------------------
resource "aws_iam_role" "restore" {
  count = local.vault_enabled ? 1 : 0

  name = "${var.name_prefix}-dr-restore-role"

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
  count = local.vault_enabled ? 1 : 0

  role       = aws_iam_role.restore[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
}

resource "aws_iam_role_policy" "restore_additional" {
  count = local.vault_enabled ? 1 : 0

  name = "${var.name_prefix}-dr-restore-additional"
  role = aws_iam_role.restore[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EC2Restore"
        Effect = "Allow"
        Action = [
          "ec2:RunInstances",
          "ec2:CreateVolume",
          "ec2:CreateTags",
          "ec2:DescribeImages",
          "ec2:DescribeInstances",
          "ec2:DescribeSnapshots",
          "ec2:DescribeVolumes",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups"
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
        Resource = var.kms_key_arn
      }
    ]
  })
}

#------------------------------------------------------------------------------
# SNS Notifications for DR Vault
#------------------------------------------------------------------------------
resource "aws_backup_vault_notifications" "dr" {
  count = local.vault_enabled && var.sns_topic_arn != "" ? 1 : 0

  backup_vault_name   = aws_backup_vault.dr[0].name
  sns_topic_arn       = var.sns_topic_arn
  backup_vault_events = [
    "COPY_JOB_STARTED",
    "COPY_JOB_SUCCESSFUL",
    "COPY_JOB_FAILED",
    "RESTORE_JOB_STARTED",
    "RESTORE_JOB_COMPLETED",
    "RESTORE_JOB_FAILED"
  ]
}
