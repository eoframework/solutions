#------------------------------------------------------------------------------
# AWS Backup Vault Module Outputs
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
