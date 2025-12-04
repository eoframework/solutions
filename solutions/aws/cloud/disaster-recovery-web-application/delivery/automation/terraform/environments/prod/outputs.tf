#------------------------------------------------------------------------------
# DR Web Application - Production Environment Outputs
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Network
#------------------------------------------------------------------------------
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.core.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.core.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.core.private_subnet_ids
}

#------------------------------------------------------------------------------
# Compute
#------------------------------------------------------------------------------
output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.core.alb_dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value       = module.core.alb_zone_id
}

output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = module.core.asg_name
}

#------------------------------------------------------------------------------
# Database
#------------------------------------------------------------------------------
output "aurora_cluster_endpoint" {
  description = "Writer endpoint of the Aurora cluster"
  value       = module.database.cluster_endpoint
}

output "aurora_cluster_reader_endpoint" {
  description = "Reader endpoint of the Aurora cluster"
  value       = module.database.cluster_reader_endpoint
}

output "aurora_global_cluster_id" {
  description = "ID of the Aurora Global Cluster"
  value       = module.database.global_cluster_id
}

#------------------------------------------------------------------------------
# Storage
#------------------------------------------------------------------------------
output "s3_bucket_id" {
  description = "ID of the S3 bucket"
  value       = module.storage.bucket_id
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = module.storage.bucket_arn
}

#------------------------------------------------------------------------------
# DR
#------------------------------------------------------------------------------
output "dr_bucket_arn" {
  description = "ARN of the DR S3 bucket"
  value       = module.dr.dr_bucket_arn
}

output "dr_kms_key_arn" {
  description = "ARN of the DR KMS key"
  value       = module.dr.dr_kms_key_arn
}

output "health_check_id" {
  description = "ID of the Route 53 health check"
  value       = module.dr.health_check_id
}

#------------------------------------------------------------------------------
# Monitoring
#------------------------------------------------------------------------------
output "sns_topic_arn" {
  description = "ARN of the SNS topic for alerts"
  value       = module.monitoring.sns_topic_arn
}

output "dashboard_name" {
  description = "Name of the CloudWatch dashboard"
  value       = module.monitoring.dashboard_name
}

#------------------------------------------------------------------------------
# Security
#------------------------------------------------------------------------------
output "kms_key_arn" {
  description = "ARN of the KMS key"
  value       = module.security.kms_key_arn
}
