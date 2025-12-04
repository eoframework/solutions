#------------------------------------------------------------------------------
# Backup Module Outputs
#------------------------------------------------------------------------------

output "backup_vault_arn" {
  description = "Backup vault ARN"
  value       = aws_backup_vault.main.arn
}

output "backup_vault_name" {
  description = "Backup vault name"
  value       = aws_backup_vault.main.name
}

output "backup_plan_id" {
  description = "Backup plan ID"
  value       = aws_backup_plan.main.id
}

output "backup_plan_arn" {
  description = "Backup plan ARN"
  value       = aws_backup_plan.main.arn
}

output "cross_region_vault_arn" {
  description = "Cross-region backup vault ARN"
  value       = var.backup.enable_cross_region ? aws_backup_vault.cross_region[0].arn : ""
}

output "backup_role_arn" {
  description = "Backup IAM role ARN"
  value       = aws_iam_role.backup.arn
}
