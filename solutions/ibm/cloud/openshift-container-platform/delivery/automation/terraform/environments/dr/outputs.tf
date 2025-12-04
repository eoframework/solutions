#==============================================================================
# OpenShift Container Platform - DR Environment Outputs
#==============================================================================

output "cluster_name" {
  description = "OpenShift DR cluster name"
  value       = var.cluster.name
}

output "api_server_url" {
  description = "OpenShift API server URL"
  value       = "https://${module.core.api_fqdn}:6443"
}

output "console_url" {
  description = "OpenShift web console URL"
  value       = "https://${module.core.console_fqdn}"
}

output "apps_wildcard_domain" {
  description = "Application ingress wildcard domain"
  value       = module.core.apps_wildcard_fqdn
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
    replication = var.dr.replication_enabled
  }
}

output "failover_runbook" {
  description = "DR failover runbook reference"
  value       = "See: delivery/automation/terraform/docs/DR_RUNBOOK.md"
}

output "environment_summary" {
  description = "Environment deployment summary"
  value = {
    environment     = "Disaster Recovery"
    cluster_name    = var.cluster.name
    cluster_version = var.cluster.version
    control_planes  = var.compute.control_plane_count
    workers         = var.compute.worker_count
    backup_enabled  = var.backup.enabled
    dr_enabled      = var.dr.enabled
    dr_strategy     = var.dr.strategy
  }
}
