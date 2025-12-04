#==============================================================================
# Ansible Automation Platform - Test Environment Outputs
#==============================================================================

output "controller_url" {
  description = "AAP Controller URL"
  value       = module.core.controller_url
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.core.vpc_id
}

output "environment_summary" {
  description = "Environment deployment summary"
  value = {
    environment      = "Test"
    controller_count = var.compute.controller_count
    execution_count  = var.compute.execution_count
    managed_nodes    = var.inventory.managed_server_count + var.inventory.managed_network_count
    backup_enabled   = false
    dr_enabled       = false
  }
}
