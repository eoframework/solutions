#==============================================================================
# Ansible Automation Platform - DR Environment Outputs
#==============================================================================

output "controller_url" {
  description = "AAP Controller URL"
  value       = module.core.controller_url
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.core.vpc_id
}

output "dr_status" {
  description = "DR environment status"
  value = {
    strategy   = var.dr.strategy
    rto_hours  = var.dr.rto_hours
    rpo_hours  = var.dr.rpo_hours
    standby    = true
    replication = var.dr.db_replication_enabled
  }
}

output "failover_runbook" {
  description = "DR failover runbook reference"
  value       = "See: delivery/automation/terraform/docs/DR_RUNBOOK.md"
}

output "environment_summary" {
  description = "Environment deployment summary"
  value = {
    environment      = "Disaster Recovery"
    controller_count = var.compute.controller_count
    execution_count  = var.compute.execution_count
    managed_nodes    = var.inventory.managed_server_count + var.inventory.managed_network_count
    backup_enabled   = var.backup.enabled
    dr_enabled       = var.dr.enabled
    dr_strategy      = var.dr.strategy
  }
}
