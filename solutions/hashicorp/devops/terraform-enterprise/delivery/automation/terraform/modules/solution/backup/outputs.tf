#------------------------------------------------------------------------------
# Backup Module Outputs (Solution-Level)
#------------------------------------------------------------------------------
# Outputs reference the aws/backup provider module outputs
#------------------------------------------------------------------------------

output "backup_vault_arn" {
  description = "Backup vault ARN"
  value       = module.backup.vault_arn
}

output "backup_vault_name" {
  description = "Backup vault name"
  value       = module.backup.vault_name
}

output "backup_vault_id" {
  description = "Backup vault ID"
  value       = module.backup.vault_id
}

output "backup_plan_id" {
  description = "Backup plan ID"
  value       = module.backup.plan_id
}

output "backup_plan_arn" {
  description = "Backup plan ARN"
  value       = module.backup.plan_arn
}

output "backup_role_arn" {
  description = "Backup IAM role ARN"
  value       = module.backup.backup_role_arn
}
