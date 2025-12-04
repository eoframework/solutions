#------------------------------------------------------------------------------
# AWS Backup Vault Module (Provider-Level Primitive)
#------------------------------------------------------------------------------
# Simple backup vault resource - for DR/cross-region scenarios
#------------------------------------------------------------------------------

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

resource "aws_backup_vault" "main" {
  name        = "${var.name_prefix}-backup-vault"
  kms_key_arn = var.kms_key_arn != "" ? var.kms_key_arn : null

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-backup-vault"
  })
}
