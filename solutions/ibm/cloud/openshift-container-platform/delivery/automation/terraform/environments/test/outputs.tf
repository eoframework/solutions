#==============================================================================
# OpenShift Container Platform - Test Environment Outputs
#==============================================================================

output "cluster_name" {
  description = "OpenShift cluster name"
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

output "environment_summary" {
  description = "Environment deployment summary"
  value = {
    environment     = "Test"
    cluster_name    = var.cluster.name
    cluster_version = var.cluster.version
    control_planes  = var.compute.control_plane_count
    workers         = var.compute.worker_count
    backup_enabled  = var.backup.enabled
    dr_enabled      = false
  }
}
