#------------------------------------------------------------------------------
# OpenShift Solution - Core Module Outputs
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# VPC Outputs
#------------------------------------------------------------------------------
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = module.vpc.vpc_cidr
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

#------------------------------------------------------------------------------
# Security Group Outputs
#------------------------------------------------------------------------------
output "control_plane_security_group_id" {
  description = "Control plane security group ID"
  value       = module.security_groups.control_plane_security_group_id
}

output "worker_security_group_id" {
  description = "Worker node security group ID"
  value       = module.security_groups.worker_security_group_id
}

output "lb_security_group_id" {
  description = "Load balancer security group ID"
  value       = module.security_groups.lb_security_group_id
}

#------------------------------------------------------------------------------
# Node Outputs
#------------------------------------------------------------------------------
output "control_plane_instance_ids" {
  description = "Control plane instance IDs"
  value       = module.ocp_nodes.control_plane_instance_ids
}

output "control_plane_private_ips" {
  description = "Control plane private IPs"
  value       = module.ocp_nodes.control_plane_private_ips
}

output "worker_instance_ids" {
  description = "Worker instance IDs"
  value       = module.ocp_nodes.worker_instance_ids
}

output "worker_private_ips" {
  description = "Worker private IPs"
  value       = module.ocp_nodes.worker_private_ips
}

output "bootstrap_instance_id" {
  description = "Bootstrap instance ID"
  value       = module.ocp_nodes.bootstrap_instance_id
}

#------------------------------------------------------------------------------
# Load Balancer Outputs
#------------------------------------------------------------------------------
output "api_lb_dns_name" {
  description = "API load balancer DNS name"
  value       = module.nlb.api_lb_dns_name
}

output "ingress_lb_dns_name" {
  description = "Ingress load balancer DNS name"
  value       = module.nlb.ingress_lb_dns_name
}

#------------------------------------------------------------------------------
# DNS Outputs
#------------------------------------------------------------------------------
output "api_fqdn" {
  description = "API server FQDN"
  value       = module.dns.api_fqdn
}

output "apps_wildcard_fqdn" {
  description = "Apps wildcard FQDN"
  value       = module.dns.apps_wildcard_fqdn
}

output "console_fqdn" {
  description = "Web console FQDN"
  value       = module.dns.console_fqdn
}
