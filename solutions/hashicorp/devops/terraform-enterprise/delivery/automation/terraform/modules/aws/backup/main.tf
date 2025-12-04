#------------------------------------------------------------------------------
# AWS Backup Module (Provider-Level Primitive)
#------------------------------------------------------------------------------
# Reusable AWS Backup resources (vault, plan, selection, IAM)
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Backup Vault
#------------------------------------------------------------------------------
resource "aws_backup_vault" "main" {
  name        = "${var.name_prefix}-backup-vault"
  kms_key_arn = var.kms_key_arn != "" ? var.kms_key_arn : null

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-backup-vault"
  })
}

#------------------------------------------------------------------------------
# Backup Plan
#------------------------------------------------------------------------------
resource "aws_backup_plan" "main" {
  name = "${var.name_prefix}-backup-plan"

  # Daily backup rule
  rule {
    rule_name         = "daily-backup"
    target_vault_name = aws_backup_vault.main.name
    schedule          = var.daily_schedule

    lifecycle {
      delete_after = var.daily_retention_days
    }

    dynamic "copy_action" {
      for_each = var.enable_cross_region_copy && var.dr_vault_arn != "" ? [1] : []
      content {
        destination_vault_arn = var.dr_vault_arn
        lifecycle {
          delete_after = var.dr_retention_days
        }
      }
    }
  }

  # Weekly backup rule
  dynamic "rule" {
    for_each = var.weekly_retention_days > 0 ? [1] : []
    content {
      rule_name         = "weekly-backup"
      target_vault_name = aws_backup_vault.main.name
      schedule          = var.weekly_schedule

      lifecycle {
        delete_after = var.weekly_retention_days
      }
    }
  }

  # Monthly backup rule
  dynamic "rule" {
    for_each = var.monthly_retention_days > 0 ? [1] : []
    content {
      rule_name         = "monthly-backup"
      target_vault_name = aws_backup_vault.main.name
      schedule          = var.monthly_schedule

      lifecycle {
        delete_after       = var.monthly_retention_days
        cold_storage_after = var.cold_storage_after_days > 0 ? var.cold_storage_after_days : null
      }
    }
  }

  tags = var.common_tags
}

#------------------------------------------------------------------------------
# Backup Selection
#------------------------------------------------------------------------------
resource "aws_backup_selection" "resources" {
  count = length(var.resource_arns) > 0 ? 1 : 0

  iam_role_arn = aws_iam_role.backup.arn
  name         = "${var.name_prefix}-backup-selection"
  plan_id      = aws_backup_plan.main.id

  resources = var.resource_arns
}

resource "aws_backup_selection" "tags" {
  count = length(var.selection_tags) > 0 ? 1 : 0

  iam_role_arn = aws_iam_role.backup.arn
  name         = "${var.name_prefix}-tag-selection"
  plan_id      = aws_backup_plan.main.id

  dynamic "selection_tag" {
    for_each = var.selection_tags
    content {
      type  = "STRINGEQUALS"
      key   = selection_tag.value.key
      value = selection_tag.value.value
    }
  }
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

resource "aws_iam_role_policy_attachment" "s3_backup" {
  count = var.enable_s3_backup ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/AWSBackupServiceRolePolicyForS3Backup"
  role       = aws_iam_role.backup.name
}

resource "aws_iam_role_policy_attachment" "s3_restore" {
  count = var.enable_s3_backup ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/AWSBackupServiceRolePolicyForS3Restore"
  role       = aws_iam_role.backup.name
}
