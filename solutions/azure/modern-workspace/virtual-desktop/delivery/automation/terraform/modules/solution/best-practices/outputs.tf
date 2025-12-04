#------------------------------------------------------------------------------
# Best Practices Module Outputs
#------------------------------------------------------------------------------

output "recovery_services_vault_id" {
  description = "ID of the Recovery Services Vault"
  value       = var.backup.enabled ? azurerm_recovery_services_vault.main[0].id : null
}

output "backup_policy_id" {
  description = "ID of the backup policy"
  value       = var.backup.enabled ? azurerm_backup_policy_vm.main[0].id : null
}

output "budget_id" {
  description = "ID of the budget alert"
  value       = var.budget.enabled ? azurerm_consumption_budget_resource_group.main[0].id : null
}
