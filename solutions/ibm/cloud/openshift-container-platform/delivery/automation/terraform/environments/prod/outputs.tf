#==============================================================================
# OpenShift Container Platform - Production Environment Outputs
#==============================================================================

#------------------------------------------------------------------------------
# Cluster Access
#------------------------------------------------------------------------------
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

#------------------------------------------------------------------------------
# Network Information
#------------------------------------------------------------------------------
output "vpc_id" {
  description = "VPC ID"
  value       = module.core.vpc_id
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.core.private_subnet_ids
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.core.public_subnet_ids
}

#------------------------------------------------------------------------------
# Node Information
#------------------------------------------------------------------------------
output "control_plane_instance_ids" {
  description = "Control plane EC2 instance IDs"
  value       = module.core.control_plane_instance_ids
}

output "worker_instance_ids" {
  description = "Worker node EC2 instance IDs"
  value       = module.core.worker_instance_ids
}

output "control_plane_private_ips" {
  description = "Control plane private IP addresses"
  value       = module.core.control_plane_private_ips
}

output "worker_private_ips" {
  description = "Worker node private IP addresses"
  value       = module.core.worker_private_ips
}

#------------------------------------------------------------------------------
# Load Balancer Information
#------------------------------------------------------------------------------
output "api_lb_dns_name" {
  description = "API load balancer DNS name"
  value       = module.core.api_lb_dns_name
}

output "ingress_lb_dns_name" {
  description = "Ingress load balancer DNS name"
  value       = module.core.ingress_lb_dns_name
}

#------------------------------------------------------------------------------
# Backup Information
#------------------------------------------------------------------------------
output "backup_bucket_name" {
  description = "S3 backup bucket name"
  value       = module.operations.backup_bucket_id
}

#------------------------------------------------------------------------------
# Environment Summary
#------------------------------------------------------------------------------
output "environment_summary" {
  description = "Environment deployment summary"
  value = {
    environment     = "Production"
    cluster_name    = var.cluster.name
    cluster_version = var.cluster.version
    control_planes  = var.compute.control_plane_count
    workers         = var.compute.worker_count
    backup_enabled  = var.backup.enabled
    dr_enabled      = var.dr.enabled
  }
}
