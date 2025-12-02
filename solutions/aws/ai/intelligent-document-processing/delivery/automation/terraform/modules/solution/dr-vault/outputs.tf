#------------------------------------------------------------------------------
# IDP DR Vault Module - Outputs
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# KMS Key
#------------------------------------------------------------------------------

output "kms_key_arn" {
  description = "ARN of the DR KMS key"
  value       = var.dr.vault_enabled ? aws_kms_key.dr[0].arn : null
}

output "kms_key_id" {
  description = "ID of the DR KMS key"
  value       = var.dr.vault_enabled ? aws_kms_key.dr[0].key_id : null
}

#------------------------------------------------------------------------------
# S3 Bucket (Replication Destination)
#------------------------------------------------------------------------------

output "bucket_arn" {
  description = "ARN of the DR S3 bucket"
  value       = var.dr.vault_enabled ? aws_s3_bucket.dr_documents[0].arn : null
}

output "bucket_id" {
  description = "ID (name) of the DR S3 bucket"
  value       = var.dr.vault_enabled ? aws_s3_bucket.dr_documents[0].id : null
}

output "bucket_domain_name" {
  description = "Domain name of the DR S3 bucket"
  value       = var.dr.vault_enabled ? aws_s3_bucket.dr_documents[0].bucket_domain_name : null
}

#------------------------------------------------------------------------------
# Backup Vault
#------------------------------------------------------------------------------

output "vault_arn" {
  description = "ARN of the DR backup vault"
  value       = var.dr.vault_enabled ? aws_backup_vault.dr[0].arn : null
}

output "vault_name" {
  description = "Name of the DR backup vault"
  value       = var.dr.vault_enabled ? aws_backup_vault.dr[0].name : null
}

output "vault_lock_enabled" {
  description = "Whether vault lock is enabled"
  value       = var.dr.vault_enabled && var.dr.vault_enable_lock
}

#------------------------------------------------------------------------------
# IAM Role
#------------------------------------------------------------------------------

output "restore_role_arn" {
  description = "ARN of the IAM role for restore operations"
  value       = var.dr.vault_enabled ? aws_iam_role.restore[0].arn : null
}

#------------------------------------------------------------------------------
# SNS Topic
#------------------------------------------------------------------------------

output "notifications_topic_arn" {
  description = "ARN of the DR notifications SNS topic"
  value       = var.dr.vault_enabled ? aws_sns_topic.dr_notifications[0].arn : null
}

#------------------------------------------------------------------------------
# Status
#------------------------------------------------------------------------------

output "enabled" {
  description = "Whether DR vault is enabled"
  value       = var.dr.vault_enabled
}

output "region" {
  description = "DR region"
  value       = var.dr.vault_enabled ? data.aws_region.current.id : null
}

#------------------------------------------------------------------------------
# Summary
#------------------------------------------------------------------------------

output "summary" {
  description = "DR vault configuration summary"
  value = var.dr.vault_enabled ? {
    enabled            = true
    region             = data.aws_region.current.id
    kms_key_arn        = aws_kms_key.dr[0].arn
    bucket_arn         = aws_s3_bucket.dr_documents[0].arn
    bucket_id          = aws_s3_bucket.dr_documents[0].id
    vault_name         = aws_backup_vault.dr[0].name
    vault_arn          = aws_backup_vault.dr[0].arn
    vault_lock_enabled = var.dr.vault_enable_lock
    restore_role_arn   = aws_iam_role.restore[0].arn
  } : {
    enabled = false
  }
}
