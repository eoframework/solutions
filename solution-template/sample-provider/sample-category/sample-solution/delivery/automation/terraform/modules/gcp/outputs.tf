# Google Cloud Module Outputs
# Outputs from GCP-specific resources

# Project Information
output "project_id" {
  description = "GCP project ID"
  value       = var.project_id
}

# Networking Outputs
output "vpc_name" {
  description = "Name of the VPC network"
  value       = module.networking.vpc_name
}

output "vpc_self_link" {
  description = "Self-link of the VPC network"
  value       = module.networking.vpc_self_link
}

output "subnet_names" {
  description = "Names of the subnets"
  value       = module.networking.subnet_names
}

output "subnet_self_links" {
  description = "Self-links of the subnets"
  value       = module.networking.subnet_self_links
}

# Security Outputs
output "firewall_rules" {
  description = "Names of the firewall rules"
  value       = module.security.firewall_rules
}

output "iam_policy_etags" {
  description = "ETags of the IAM policies"
  value       = module.security.iam_policy_etags
}

# Compute Outputs
output "instance_names" {
  description = "Names of the Compute Engine instances"
  value       = module.compute.instance_names
}

output "instance_self_links" {
  description = "Self-links of the Compute Engine instances"
  value       = module.compute.instance_self_links
}

output "external_ips" {
  description = "External IP addresses of the instances"
  value       = module.compute.external_ips
}

output "internal_ips" {
  description = "Internal IP addresses of the instances"
  value       = module.compute.internal_ips
}

output "instance_group_manager_name" {
  description = "Name of the Instance Group Manager"
  value       = module.compute.instance_group_manager_name
}

output "load_balancer_ip" {
  description = "IP address of the load balancer"
  value       = module.compute.load_balancer_ip
}

output "sql_instance_name" {
  description = "Name of the Cloud SQL instance"
  value       = module.compute.sql_instance_name
  sensitive   = true
}

output "sql_connection_name" {
  description = "Connection name of the Cloud SQL instance"
  value       = module.compute.sql_connection_name
  sensitive   = true
}

output "sql_ip_address" {
  description = "IP address of the Cloud SQL instance"
  value       = module.compute.sql_ip_address
  sensitive   = true
}

# Resource Summary
output "gcp_resource_summary" {
  description = "Summary of GCP resources created"
  value = {
    project_id            = var.project_id
    region               = var.region
    vpc_cidr            = var.vpc_cidr
    subnets_created     = length(var.subnets)
    instances_created   = length(var.instances)
    instance_group_enabled = var.enable_instance_group
    load_balancer_enabled  = var.enable_load_balancer
    iam_policies_enabled   = var.enable_iam_policies
  }
}