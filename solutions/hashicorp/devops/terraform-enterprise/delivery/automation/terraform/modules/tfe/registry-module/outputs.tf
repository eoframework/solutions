#------------------------------------------------------------------------------
# TFE Registry Module Outputs
#------------------------------------------------------------------------------

output "module_ids" {
  description = "Map of module names to IDs"
  value       = { for k, v in tfe_registry_module.module : k => v.id }
}

output "module_names" {
  description = "List of registered module names"
  value       = [for k, v in tfe_registry_module.module : v.name]
}

output "nocode_module_ids" {
  description = "Map of no-code module names to IDs"
  value       = { for k, v in tfe_no_code_module.nocode : k => v.id }
}
