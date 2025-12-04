#------------------------------------------------------------------------------
# Backup Module
#------------------------------------------------------------------------------
# AWS Backup for database and EBS snapshots
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Backup Vault
#------------------------------------------------------------------------------
resource "aws_backup_vault" "main" {
  name        = "${var.name_prefix}-backup-vault"
  kms_key_arn = var.kms_key_arn

  tags = var.common_tags
}

#------------------------------------------------------------------------------
# Backup Plan
#------------------------------------------------------------------------------
resource "aws_backup_plan" "main" {
  name = "${var.name_prefix}-backup-plan"

  rule {
    rule_name         = "daily-backup"
    target_vault_name = aws_backup_vault.main.name
    schedule          = var.backup.daily_schedule

    lifecycle {
      delete_after = var.backup.retention_days
    }

    copy_action {
      destination_vault_arn = var.backup.enable_cross_region ? aws_backup_vault.cross_region[0].arn : null

      lifecycle {
        delete_after = var.backup.cross_region_retention_days
      }
    }
  }

  dynamic "rule" {
    for_each = var.backup.enable_weekly ? [1] : []
    content {
      rule_name         = "weekly-backup"
      target_vault_name = aws_backup_vault.main.name
      schedule          = var.backup.weekly_schedule

      lifecycle {
        delete_after = var.backup.weekly_retention_days
      }
    }
  }

  tags = var.common_tags
}

#------------------------------------------------------------------------------
# Backup Selection
#------------------------------------------------------------------------------
resource "aws_backup_selection" "main" {
  name         = "${var.name_prefix}-backup-selection"
  plan_id      = aws_backup_plan.main.id
  iam_role_arn = aws_iam_role.backup.arn

  selection_tag {
    type  = "STRINGEQUALS"
    key   = "Backup"
    value = "true"
  }
}

#------------------------------------------------------------------------------
# Cross-Region Backup Vault
#------------------------------------------------------------------------------
resource "aws_backup_vault" "cross_region" {
  count = var.backup.enable_cross_region ? 1 : 0

  provider    = aws.dr
  name        = "${var.name_prefix}-backup-vault-dr"
  kms_key_arn = var.backup.dr_kms_key_arn

  tags = var.common_tags
}

#------------------------------------------------------------------------------
# IAM Role for Backup
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
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
  role       = aws_iam_role.backup.name
}

resource "aws_iam_role_policy_attachment" "restore" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
  role       = aws_iam_role.backup.name
}
