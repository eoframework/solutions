# AWS Backup Plans Module
# Pillar: Reliability
#
# Implements centralized backup management using AWS Backup.
# Supports cross-region copy for disaster recovery.

#------------------------------------------------------------------------------
# Backup Vault
#------------------------------------------------------------------------------

resource "aws_backup_vault" "main" {
  name        = "${var.name_prefix}-backup-vault"
  kms_key_arn = var.kms_key_arn

  tags = merge(var.common_tags, {
    Name   = "${var.name_prefix}-backup-vault"
    Pillar = "Reliability"
  })
}

resource "aws_backup_vault_policy" "main" {
  count = var.enable_vault_policy ? 1 : 0

  backup_vault_name = aws_backup_vault.main.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowBackupService"
        Effect = "Allow"
        Principal = {
          Service = "backup.amazonaws.com"
        }
        Action = [
          "backup:CopyIntoBackupVault"
        ]
        Resource = "*"
      }
    ]
  })
}

#------------------------------------------------------------------------------
# Cross-Region Backup Vault (for DR)
#------------------------------------------------------------------------------

resource "aws_backup_vault" "dr" {
  count    = var.enable_cross_region_copy ? 1 : 0
  provider = aws.dr

  name        = "${var.name_prefix}-backup-vault-dr"
  kms_key_arn = var.dr_kms_key_arn

  tags = merge(var.common_tags, {
    Name   = "${var.name_prefix}-backup-vault-dr"
    Pillar = "Reliability"
    Type   = "DisasterRecovery"
  })
}

#------------------------------------------------------------------------------
# Backup Plan - Daily
#------------------------------------------------------------------------------

resource "aws_backup_plan" "daily" {
  name = "${var.name_prefix}-daily-backup"

  rule {
    rule_name         = "daily-backup"
    target_vault_name = aws_backup_vault.main.name
    schedule          = var.daily_backup_schedule

    lifecycle {
      delete_after = var.daily_retention_days
    }

    # Cross-region copy for disaster recovery
    dynamic "copy_action" {
      for_each = var.enable_cross_region_copy ? [1] : []
      content {
        destination_vault_arn = aws_backup_vault.dr[0].arn
        lifecycle {
          delete_after = var.dr_retention_days
        }
      }
    }

    # Enable continuous backup for point-in-time recovery (RDS, S3)
    enable_continuous_backup = var.enable_continuous_backup
  }

  # Optional: Weekly backup with longer retention
  dynamic "rule" {
    for_each = var.enable_weekly_backup ? [1] : []
    content {
      rule_name         = "weekly-backup"
      target_vault_name = aws_backup_vault.main.name
      schedule          = var.weekly_backup_schedule

      lifecycle {
        delete_after = var.weekly_retention_days
      }

      dynamic "copy_action" {
        for_each = var.enable_cross_region_copy ? [1] : []
        content {
          destination_vault_arn = aws_backup_vault.dr[0].arn
          lifecycle {
            delete_after = var.dr_retention_days
          }
        }
      }
    }
  }

  # Optional: Monthly backup with even longer retention
  dynamic "rule" {
    for_each = var.enable_monthly_backup ? [1] : []
    content {
      rule_name         = "monthly-backup"
      target_vault_name = aws_backup_vault.main.name
      schedule          = var.monthly_backup_schedule

      lifecycle {
        cold_storage_after = var.monthly_cold_storage_days
        delete_after       = var.monthly_retention_days
      }

      dynamic "copy_action" {
        for_each = var.enable_cross_region_copy ? [1] : []
        content {
          destination_vault_arn = aws_backup_vault.dr[0].arn
          lifecycle {
            delete_after = var.dr_retention_days
          }
        }
      }
    }
  }

  advanced_backup_setting {
    backup_options = {
      WindowsVSS = var.enable_windows_vss ? "enabled" : "disabled"
    }
    resource_type = "EC2"
  }

  tags = merge(var.common_tags, {
    Name   = "${var.name_prefix}-daily-backup"
    Pillar = "Reliability"
  })
}

#------------------------------------------------------------------------------
# Backup Selection - By Tags
#------------------------------------------------------------------------------

resource "aws_backup_selection" "tagged_resources" {
  count = var.enable_tag_based_selection ? 1 : 0

  iam_role_arn = aws_iam_role.backup.arn
  name         = "${var.name_prefix}-tagged-resources"
  plan_id      = aws_backup_plan.daily.id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = var.backup_tag_key
    value = var.backup_tag_value
  }
}

#------------------------------------------------------------------------------
# Backup Selection - Specific Resources
#------------------------------------------------------------------------------

resource "aws_backup_selection" "specific_resources" {
  count = length(var.resource_arns) > 0 ? 1 : 0

  iam_role_arn = aws_iam_role.backup.arn
  name         = "${var.name_prefix}-specific-resources"
  plan_id      = aws_backup_plan.daily.id

  resources = var.resource_arns
}

#------------------------------------------------------------------------------
# IAM Role for AWS Backup
#------------------------------------------------------------------------------

resource "aws_iam_role" "backup" {
  name = "${var.name_prefix}-backup-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "backup.amazonaws.com"
      }
    }]
  })

  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "backup" {
  role       = aws_iam_role.backup.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

resource "aws_iam_role_policy_attachment" "restore" {
  role       = aws_iam_role.backup.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
}

# Additional policy for S3 backup (if enabled)
resource "aws_iam_role_policy_attachment" "s3_backup" {
  count = var.enable_s3_backup ? 1 : 0

  role       = aws_iam_role.backup.name
  policy_arn = "arn:aws:iam::aws:policy/AWSBackupServiceRolePolicyForS3Backup"
}

resource "aws_iam_role_policy_attachment" "s3_restore" {
  count = var.enable_s3_backup ? 1 : 0

  role       = aws_iam_role.backup.name
  policy_arn = "arn:aws:iam::aws:policy/AWSBackupServiceRolePolicyForS3Restore"
}

#------------------------------------------------------------------------------
# Backup Vault Lock (Optional - for compliance)
#------------------------------------------------------------------------------

resource "aws_backup_vault_lock_configuration" "main" {
  count = var.enable_vault_lock ? 1 : 0

  backup_vault_name   = aws_backup_vault.main.name
  min_retention_days  = var.vault_lock_min_retention
  max_retention_days  = var.vault_lock_max_retention
  changeable_for_days = var.vault_lock_changeable_days
}

#------------------------------------------------------------------------------
# SNS Notifications
#------------------------------------------------------------------------------

resource "aws_backup_vault_notifications" "main" {
  count = var.sns_topic_arn != "" ? 1 : 0

  backup_vault_name   = aws_backup_vault.main.name
  sns_topic_arn       = var.sns_topic_arn
  backup_vault_events = var.notification_events
}
