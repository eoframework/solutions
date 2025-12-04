#==============================================================================
# Ansible Automation Platform - Production Environment Outputs
#==============================================================================

output "controller_url" {
  description = "AAP Controller URL"
  value       = module.core.controller_url
}

output "controller_lb_dns_name" {
  description = "Controller ALB DNS name"
  value       = module.core.controller_lb_dns_name
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.core.vpc_id
}

output "controller_instance_ids" {
  description = "Controller EC2 instance IDs"
  value       = module.core.controller_instance_ids
}

output "execution_instance_ids" {
  description = "Execution node EC2 instance IDs"
  value       = module.core.execution_instance_ids
}

output "hub_instance_id" {
  description = "Hub EC2 instance ID"
  value       = module.core.hub_instance_id
}

output "database_endpoint" {
  description = "Database endpoint"
  value       = module.core.database_endpoint
  sensitive   = true
}

output "environment_summary" {
  description = "Environment deployment summary"
  value = {
    environment      = "Production"
    controller_count = var.compute.controller_count
    execution_count  = var.compute.execution_count
    managed_nodes    = var.inventory.managed_server_count + var.inventory.managed_network_count
    backup_enabled   = var.backup.enabled
    dr_enabled       = var.dr.enabled
  }
}
