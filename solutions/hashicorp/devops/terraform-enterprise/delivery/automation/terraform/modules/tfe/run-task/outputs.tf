#------------------------------------------------------------------------------
# TFE Run Task Module Outputs
#------------------------------------------------------------------------------

output "run_task_ids" {
  description = "Map of run task names to IDs"
  value       = { for k, v in tfe_organization_run_task.task : k => v.id }
}

output "run_task_names" {
  description = "List of run task names"
  value       = [for k, v in tfe_organization_run_task.task : v.name]
}
