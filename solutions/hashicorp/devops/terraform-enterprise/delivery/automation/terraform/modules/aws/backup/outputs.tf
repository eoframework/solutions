#------------------------------------------------------------------------------
# AWS Backup Module Outputs
#------------------------------------------------------------------------------

output "vault_id" {
  description = "Backup vault ID"
  value       = aws_backup_vault.main.id
}

output "vault_arn" {
  description = "Backup vault ARN"
  value       = aws_backup_vault.main.arn
}

output "vault_name" {
  description = "Backup vault name"
  value       = aws_backup_vault.main.name
}

output "plan_id" {
  description = "Backup plan ID"
  value       = aws_backup_plan.main.id
}

output "plan_arn" {
  description = "Backup plan ARN"
  value       = aws_backup_plan.main.arn
}

output "backup_role_arn" {
  description = "IAM role ARN for backup operations"
  value       = aws_iam_role.backup.arn
}

output "backup_role_name" {
  description = "IAM role name for backup operations"
  value       = aws_iam_role.backup.name
}
