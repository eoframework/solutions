#------------------------------------------------------------------------------
# IDP DR Replication Module - Outputs
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# S3 Replication
#------------------------------------------------------------------------------

output "s3_replication_role_arn" {
  description = "ARN of the S3 replication IAM role"
  value       = var.dr.enabled ? aws_iam_role.s3_replication[0].arn : null
}

#------------------------------------------------------------------------------
# DynamoDB Replication
#------------------------------------------------------------------------------

output "dynamodb_replication_role_arn" {
  description = "ARN of the DynamoDB replication IAM role"
  value       = var.dr.enabled ? aws_iam_role.dynamodb_replication[0].arn : null
}

#------------------------------------------------------------------------------
# AWS Backup
#------------------------------------------------------------------------------

output "backup_vault_arn" {
  description = "ARN of the source backup vault"
  value       = var.dr.enabled ? aws_backup_vault.source[0].arn : null
}

output "backup_vault_name" {
  description = "Name of the source backup vault"
  value       = var.dr.enabled ? aws_backup_vault.source[0].name : null
}

output "backup_plan_id" {
  description = "ID of the DynamoDB backup plan"
  value       = var.dr.enabled ? aws_backup_plan.dynamodb[0].id : null
}

output "backup_plan_arn" {
  description = "ARN of the DynamoDB backup plan"
  value       = var.dr.enabled ? aws_backup_plan.dynamodb[0].arn : null
}

output "backup_role_arn" {
  description = "ARN of the IAM role used for backups"
  value       = var.dr.enabled ? aws_iam_role.backup[0].arn : null
}

#------------------------------------------------------------------------------
# DR Configuration
#------------------------------------------------------------------------------

output "dr_vault_arn" {
  description = "ARN of the DR destination vault (in DR region)"
  value       = var.dr.enabled ? var.dr.dr_vault_arn : null
}

output "dr_region" {
  description = "DR region where data is replicated to"
  value       = var.dr.enabled ? var.dr.dr_region : null
}

output "dr_bucket_arn" {
  description = "ARN of the DR S3 bucket (replica)"
  value       = var.dr.enabled ? var.dr.dr_bucket_arn : null
}

output "enabled" {
  description = "Whether DR replication is enabled"
  value       = var.dr.enabled
}

#------------------------------------------------------------------------------
# Summary
#------------------------------------------------------------------------------

output "summary" {
  description = "DR replication configuration summary"
  value = var.dr.enabled ? {
    enabled              = true
    source_vault         = aws_backup_vault.source[0].name
    dr_region            = var.dr.dr_region
    dr_vault_arn         = var.dr.dr_vault_arn
    dr_bucket_arn        = var.dr.dr_bucket_arn
    local_retention_days = var.dr.backup_local_retention_days
    dr_retention_days    = var.dr.backup_retention_days
    weekly_enabled       = var.dr.enable_weekly_backup
    replication_type = {
      s3       = "Cross-Region Replication (CRR)"
      dynamodb = "AWS Backup with Cross-Region Copy"
    }
  } : {
    enabled = false
  }
}
