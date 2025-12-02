#------------------------------------------------------------------------------
# Consolidated DR Module - Outputs
#------------------------------------------------------------------------------

output "source_vault_arn" {
  description = "Source backup vault ARN (production)"
  value       = length(aws_backup_vault.source) > 0 ? aws_backup_vault.source[0].arn : null
}

output "source_vault_name" {
  description = "Source backup vault name (production)"
  value       = length(aws_backup_vault.source) > 0 ? aws_backup_vault.source[0].name : null
}

output "dr_vault_arn" {
  description = "DR backup vault ARN (DR environment)"
  value       = length(aws_backup_vault.dr) > 0 ? aws_backup_vault.dr[0].arn : null
}

output "dr_vault_name" {
  description = "DR backup vault name (DR environment)"
  value       = length(aws_backup_vault.dr) > 0 ? aws_backup_vault.dr[0].name : null
}

output "backup_plan_id" {
  description = "Backup plan ID (production)"
  value       = length(aws_backup_plan.dr) > 0 ? aws_backup_plan.dr[0].id : null
}

output "backup_role_arn" {
  description = "Backup IAM role ARN"
  value       = length(aws_iam_role.backup) > 0 ? aws_iam_role.backup[0].arn : null
}

output "restore_role_arn" {
  description = "Restore IAM role ARN (DR environment)"
  value       = length(aws_iam_role.restore) > 0 ? aws_iam_role.restore[0].arn : null
}

output "replication_enabled" {
  description = "Whether DR replication is enabled"
  value       = local.replication_enabled
}

output "vault_enabled" {
  description = "Whether DR vault is enabled"
  value       = local.vault_enabled
}
