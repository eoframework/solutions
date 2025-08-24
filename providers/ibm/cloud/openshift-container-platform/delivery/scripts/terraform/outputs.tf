# Outputs for IBM OpenShift Container Platform deployment

# Cluster Information
output "cluster_id" {
  description = "ID of the OpenShift cluster"
  value       = rhcs_cluster_rosa_classic.openshift_cluster.id
}

output "cluster_name" {
  description = "Name of the OpenShift cluster"
  value       = rhcs_cluster_rosa_classic.openshift_cluster.name
}

output "cluster_state" {
  description = "State of the OpenShift cluster"
  value       = rhcs_cluster_rosa_classic.openshift_cluster.state
}

output "cluster_version" {
  description = "Version of the OpenShift cluster"
  value       = rhcs_cluster_rosa_classic.openshift_cluster.version
}

# Cluster Access Information
output "cluster_api_url" {
  description = "OpenShift cluster API URL"
  value       = rhcs_cluster_rosa_classic.openshift_cluster.api_url
}

output "cluster_console_url" {
  description = "OpenShift cluster console URL"
  value       = rhcs_cluster_rosa_classic.openshift_cluster.console_url
}

output "cluster_login_command" {
  description = "Command to login to the cluster"
  value       = "oc login ${rhcs_cluster_rosa_classic.openshift_cluster.api_url} --username kubeadmin"
  sensitive   = false
}

# Network Information
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.openshift_vpc.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.openshift_vpc.cidr_block
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public_subnets[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private_subnets[*].id
}

output "availability_zones" {
  description = "Availability zones used by the cluster"
  value       = local.availability_zones
}

output "nat_gateway_ips" {
  description = "Public IP addresses of NAT gateways"
  value       = aws_eip.nat_eips[*].public_ip
}

# Security Information
output "security_group_id" {
  description = "ID of the cluster security group"
  value       = aws_security_group.openshift_cluster_sg.id
}

output "kms_key_id" {
  description = "ID of the KMS key used for encryption"
  value       = aws_kms_key.openshift_kms_key.id
}

output "kms_key_arn" {
  description = "ARN of the KMS key used for encryption"
  value       = aws_kms_key.openshift_kms_key.arn
}

# SSH Access Information
output "ssh_key_name" {
  description = "Name of the SSH key pair"
  value       = aws_key_pair.cluster_key_pair.key_name
}

output "ssh_private_key_secret_arn" {
  description = "ARN of the secret containing SSH private key"
  value       = aws_secretsmanager_secret.cluster_private_key.arn
}

# Machine Pool Information
output "compute_machine_type" {
  description = "Instance type of compute nodes"
  value       = local.compute_machine_type
}

output "compute_replicas" {
  description = "Number of compute nodes"
  value       = local.compute_replicas
}

output "additional_machine_pool_id" {
  description = "ID of additional machine pool (if created)"
  value       = var.enable_additional_machine_pool ? rhcs_machine_pool.additional_workers[0].id : null
}

# Storage Information
output "s3_bucket_name" {
  description = "Name of S3 bucket for cluster storage (if created)"
  value       = var.create_s3_storage ? aws_s3_bucket.cluster_storage[0].id : null
}

output "s3_bucket_arn" {
  description = "ARN of S3 bucket for cluster storage (if created)"
  value       = var.create_s3_storage ? aws_s3_bucket.cluster_storage[0].arn : null
}

# DNS Information
output "route53_zone_id" {
  description = "Route53 hosted zone ID (if created)"
  value       = var.manage_dns ? aws_route53_zone.cluster_zone[0].zone_id : null
}

output "route53_zone_name_servers" {
  description = "Name servers for Route53 hosted zone (if created)"
  value       = var.manage_dns ? aws_route53_zone.cluster_zone[0].name_servers : null
}

output "cluster_domain" {
  description = "Domain name configured for the cluster"
  value       = var.cluster_domain
}

# Load Balancer Information
output "additional_alb_dns_name" {
  description = "DNS name of additional ALB (if created)"
  value       = var.create_additional_alb ? aws_lb.openshift_alb[0].dns_name : null
}

output "additional_alb_zone_id" {
  description = "Zone ID of additional ALB (if created)"
  value       = var.create_additional_alb ? aws_lb.openshift_alb[0].zone_id : null
}

# Identity Provider Information
output "identity_provider_name" {
  description = "Name of configured identity provider (if any)"
  value       = var.identity_provider_type != "" ? var.identity_provider_name : null
}

output "identity_provider_type" {
  description = "Type of configured identity provider"
  value       = var.identity_provider_type != "" ? var.identity_provider_type : null
}

# Cluster Configuration Summary
output "deployment_summary" {
  description = "Summary of cluster deployment configuration"
  value = {
    cluster_name         = rhcs_cluster_rosa_classic.openshift_cluster.name
    cluster_version      = rhcs_cluster_rosa_classic.openshift_cluster.version
    deployment_type      = var.deployment_type
    aws_region          = var.aws_region
    availability_zones   = local.availability_zones
    compute_nodes       = local.compute_replicas
    machine_type        = local.compute_machine_type
    multi_az            = var.deployment_type != "single-az"
    private_cluster     = var.deployment_type == "private"
    fips_enabled        = var.deployment_type == "fips"
    etcd_encryption     = var.enable_etcd_encryption
    autoscaling_enabled = var.enable_autoscaling
    identity_provider   = var.identity_provider_type
    s3_storage         = var.create_s3_storage
    dns_management     = var.manage_dns
  }
}

# Connection Instructions
output "connection_instructions" {
  description = "Instructions for connecting to the cluster"
  value = <<-EOT
    # IBM OpenShift Container Platform - Connection Instructions
    
    ## Cluster Information
    - Cluster Name: ${rhcs_cluster_rosa_classic.openshift_cluster.name}
    - OpenShift Version: ${rhcs_cluster_rosa_classic.openshift_cluster.version}
    - AWS Region: ${var.aws_region}
    
    ## Access URLs
    - API Server: ${rhcs_cluster_rosa_classic.openshift_cluster.api_url}
    - Web Console: ${rhcs_cluster_rosa_classic.openshift_cluster.console_url}
    
    ## CLI Access
    1. Install the OpenShift CLI (oc):
       curl -L https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-linux.tar.gz | tar xzf -
    
    2. Login to the cluster:
       oc login ${rhcs_cluster_rosa_classic.openshift_cluster.api_url} --username kubeadmin
    
    3. Get kubeadmin password:
       rosa describe cluster ${rhcs_cluster_rosa_classic.openshift_cluster.name} --output json | jq -r .api.admin_password
    
    ## Web Console Access
    - Open: ${rhcs_cluster_rosa_classic.openshift_cluster.console_url}
    - Username: kubeadmin
    - Password: (retrieve using rosa CLI as shown above)
    
    ## SSH Access to Nodes (if needed)
    - SSH Key: ${aws_key_pair.cluster_key_pair.key_name}
    - Private Key: Stored in AWS Secrets Manager (${aws_secretsmanager_secret.cluster_private_key.arn})
    
    ## Additional Resources
    - VPC ID: ${aws_vpc.openshift_vpc.id}
    - Security Group: ${aws_security_group.openshift_cluster_sg.id}
    - KMS Key: ${aws_kms_key.openshift_kms_key.arn}
    ${var.create_s3_storage ? "- S3 Bucket: ${aws_s3_bucket.cluster_storage[0].id}" : ""}
    ${var.manage_dns ? "- Route53 Zone: ${aws_route53_zone.cluster_zone[0].name}" : ""}
  EOT
}

# Resource Tags
output "common_tags" {
  description = "Common tags applied to resources"
  value       = local.common_tags
}

# Cost Optimization Information
output "cost_optimization_info" {
  description = "Information for cost optimization"
  value = {
    compute_nodes_count    = local.compute_replicas
    compute_instance_type  = local.compute_machine_type
    deployment_type       = var.deployment_type
    autoscaling_enabled   = var.enable_autoscaling
    min_nodes            = var.enable_autoscaling ? var.min_replicas : local.compute_replicas
    max_nodes            = var.enable_autoscaling ? var.max_replicas : local.compute_replicas
    estimated_monthly_cost = "Contact IBM Red Hat Services for cost estimates"
  }
}

# Compliance Information
output "compliance_info" {
  description = "Compliance and security configuration"
  value = {
    fips_enabled         = var.deployment_type == "fips"
    etcd_encryption     = var.enable_etcd_encryption
    kms_encryption      = true
    private_cluster     = var.deployment_type == "private"
    identity_provider   = var.identity_provider_type
    compliance_scanning = var.compliance_scanning
    network_type       = var.network_type
  }
}

# Monitoring and Logging
output "observability_info" {
  description = "Monitoring and logging configuration"
  value = {
    cluster_monitoring_enabled      = var.enable_cluster_monitoring
    user_workload_monitoring       = var.enable_user_workload_monitoring
    monitoring_retention_days      = var.monitoring_retention_days
    backup_enabled                = var.enable_cluster_backup
    backup_schedule               = var.backup_schedule
    backup_retention_days         = var.backup_retention_days
  }
}