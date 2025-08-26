# HashiCorp Terraform Enterprise Platform - Outputs
# This file defines output values for the Terraform Enterprise deployment

# Network Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.tfe_vpc.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.tfe_vpc.cidr_block
}

output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = aws_subnet.public_subnets[*].id
}

output "private_subnet_ids" {
  description = "List of IDs of private subnets"
  value       = aws_subnet.private_subnets[*].id
}

output "database_subnet_ids" {
  description = "List of IDs of database subnets"
  value       = aws_subnet.database_subnets[*].id
}

# EKS Cluster Outputs
output "cluster_id" {
  description = "EKS cluster ID"
  value       = module.eks.cluster_id
}

output "cluster_arn" {
  description = "EKS cluster ARN"
  value       = module.eks.cluster_arn
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_version" {
  description = "The Kubernetes version for the EKS cluster"
  value       = module.eks.cluster_version
}

output "cluster_platform_version" {
  description = "Platform version for the EKS cluster"
  value       = module.eks.cluster_platform_version
}

output "cluster_status" {
  description = "Status of the EKS cluster"
  value       = module.eks.cluster_status
}

output "cluster_security_group_id" {
  description = "Cluster security group that was created by Amazon EKS for the cluster"
  value       = module.eks.cluster_security_group_id
}

output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster for the OpenID Connect identity provider"
  value       = module.eks.cluster_oidc_issuer_url
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.eks.cluster_certificate_authority_data
}

# Node Group Outputs
output "node_groups" {
  description = "Map of attribute maps for all EKS managed node groups created"
  value       = module.eks.eks_managed_node_groups
  sensitive   = true
}

output "node_security_group_id" {
  description = "ID of the node shared security group"
  value       = module.eks.node_security_group_id
}

# Database Outputs
output "db_instance_id" {
  description = "RDS instance ID"
  value       = aws_db_instance.tfe_database.id
}

output "db_instance_arn" {
  description = "RDS instance ARN"
  value       = aws_db_instance.tfe_database.arn
}

output "db_instance_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.tfe_database.endpoint
  sensitive   = true
}

output "db_instance_hosted_zone_id" {
  description = "RDS instance hosted zone ID"
  value       = aws_db_instance.tfe_database.hosted_zone_id
}

output "db_instance_port" {
  description = "RDS instance port"
  value       = aws_db_instance.tfe_database.port
}

output "db_instance_status" {
  description = "RDS instance status"
  value       = aws_db_instance.tfe_database.status
}

output "db_subnet_group_id" {
  description = "RDS subnet group ID"
  value       = aws_db_subnet_group.tfe_db_subnet_group.id
}

output "db_parameter_group_id" {
  description = "RDS parameter group ID"
  value       = aws_db_parameter_group.tfe_db_params.id
}

# Storage Outputs
output "s3_bucket_id" {
  description = "ID of the S3 bucket"
  value       = aws_s3_bucket.tfe_storage.id
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.tfe_storage.arn
}

output "s3_bucket_domain_name" {
  description = "Domain name of the S3 bucket"
  value       = aws_s3_bucket.tfe_storage.bucket_domain_name
}

output "s3_bucket_regional_domain_name" {
  description = "Regional domain name of the S3 bucket"
  value       = aws_s3_bucket.tfe_storage.bucket_regional_domain_name
}

# Load Balancer Outputs
output "load_balancer_arn" {
  description = "ARN of the load balancer"
  value       = aws_lb.tfe_alb.arn
}

output "load_balancer_dns_name" {
  description = "DNS name of the load balancer"
  value       = aws_lb.tfe_alb.dns_name
}

output "load_balancer_zone_id" {
  description = "Zone ID of the load balancer"
  value       = aws_lb.tfe_alb.zone_id
}

output "load_balancer_hosted_zone_id" {
  description = "Hosted zone ID of the load balancer"
  value       = aws_lb.tfe_alb.zone_id
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = aws_lb_target_group.tfe_tg.arn
}

# Security Outputs
output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.tfe_alb_sg.id
}

output "app_security_group_id" {
  description = "ID of the application security group"
  value       = aws_security_group.tfe_app_sg.id
}

output "database_security_group_id" {
  description = "ID of the database security group"
  value       = aws_security_group.tfe_db_sg.id
}

# SSL Certificate Outputs
output "acm_certificate_arn" {
  description = "ARN of the ACM certificate"
  value       = aws_acm_certificate.tfe_cert.arn
}

output "acm_certificate_domain_name" {
  description = "Domain name for which the certificate is issued"
  value       = aws_acm_certificate.tfe_cert.domain_name
}

output "acm_certificate_status" {
  description = "Status of the ACM certificate"
  value       = aws_acm_certificate.tfe_cert.status
}

# DNS Outputs
output "dns_record_name" {
  description = "Name of the DNS record"
  value       = var.create_dns_record ? aws_route53_record.tfe[0].name : null
}

output "dns_record_fqdn" {
  description = "FQDN of the DNS record"
  value       = var.create_dns_record ? aws_route53_record.tfe[0].fqdn : null
}

# Kubernetes Outputs
output "kubernetes_namespace" {
  description = "Kubernetes namespace for Terraform Enterprise"
  value       = kubernetes_namespace.terraform_enterprise.metadata[0].name
}

output "helm_release_name" {
  description = "Name of the Terraform Enterprise Helm release"
  value       = helm_release.terraform_enterprise.name
}

output "helm_release_namespace" {
  description = "Namespace of the Terraform Enterprise Helm release"
  value       = helm_release.terraform_enterprise.namespace
}

output "helm_release_version" {
  description = "Version of the Terraform Enterprise Helm chart"
  value       = helm_release.terraform_enterprise.version
}

output "helm_release_status" {
  description = "Status of the Terraform Enterprise Helm release"
  value       = helm_release.terraform_enterprise.status
}

# Secrets Outputs (non-sensitive metadata only)
output "database_secret_name" {
  description = "Name of the database credentials secret"
  value       = kubernetes_secret.tfe_database.metadata[0].name
}

output "storage_secret_name" {
  description = "Name of the storage credentials secret"
  value       = kubernetes_secret.tfe_storage.metadata[0].name
}

output "aws_secrets_manager_secret_arn" {
  description = "ARN of the AWS Secrets Manager secret for database password"
  value       = aws_secretsmanager_secret.db_password.arn
}

# CloudWatch Outputs
output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.tfe_logs.name
}

output "cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.tfe_logs.arn
}

# Access Information
output "terraform_enterprise_url" {
  description = "URL to access Terraform Enterprise"
  value       = "https://${var.domain_name}"
}

output "terraform_enterprise_admin_console_url" {
  description = "URL to access Terraform Enterprise admin console"
  value       = "https://${var.domain_name}:8800"
}

# Connection Information
output "kubectl_config_command" {
  description = "Command to configure kubectl for the EKS cluster"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}

output "database_connection_string" {
  description = "Database connection string (without password)"
  value       = "postgresql://${var.database_username}@${aws_db_instance.tfe_database.endpoint}:${aws_db_instance.tfe_database.port}/${var.database_name}"
  sensitive   = true
}

# Resource Tags
output "common_tags" {
  description = "Common tags applied to all resources"
  value       = local.common_tags
}

# Monitoring Endpoints
output "prometheus_metrics_endpoint" {
  description = "Prometheus metrics endpoint for monitoring"
  value       = "https://${var.domain_name}/metrics"
}

output "health_check_endpoint" {
  description = "Health check endpoint"
  value       = "https://${var.domain_name}/_health_check"
}

# Backup Information
output "automated_backup_enabled" {
  description = "Whether automated backups are enabled"
  value       = var.enable_backup
}

output "backup_retention_period" {
  description = "Database backup retention period in days"
  value       = aws_db_instance.tfe_database.backup_retention_period
}

# Cost Information
output "estimated_monthly_cost_components" {
  description = "Estimated monthly cost components (for reference only)"
  value = {
    eks_cluster        = "~$75/month"
    worker_nodes       = "~$150-500/month (depends on instance types and count)"
    rds_database       = "~$100-300/month (depends on instance class)"
    load_balancer      = "~$25/month"
    nat_gateways       = "~$100/month (3 AZs)"
    s3_storage         = "~$20-100/month (depends on usage)"
    data_transfer      = "Variable based on traffic"
    cloudwatch_logs    = "~$10-50/month (depends on log volume)"
  }
}

# Deployment Information
output "deployment_region" {
  description = "AWS region where resources are deployed"
  value       = var.aws_region
}

output "deployment_environment" {
  description = "Environment name for this deployment"
  value       = var.environment
}

output "deployment_timestamp" {
  description = "Timestamp when the deployment was created"
  value       = timestamp()
}

# Post-Deployment Instructions
output "next_steps" {
  description = "Next steps after deployment"
  value = [
    "1. Configure kubectl: ${module.eks.cluster_name}",
    "2. Access Terraform Enterprise at: https://${var.domain_name}",
    "3. Complete initial setup wizard",
    "4. Upload your Terraform Enterprise license",
    "5. Configure VCS integration",
    "6. Create your first workspace",
    "7. Review security settings and user access",
    "8. Set up monitoring and alerting",
    "9. Configure backup and disaster recovery procedures",
    "10. Review and customize organization settings"
  ]
}