#------------------------------------------------------------------------------
# Cloud Migration - Test Environment Outputs
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

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.core.alb_dns_name
}

output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = module.core.asg_name
}

output "vpn_gateway_id" {
  description = "ID of the VPN Gateway (null in test - VPN disabled)"
  value       = module.core.vpn_gateway_id
}

output "db_endpoint" {
  description = "Endpoint of the RDS instance"
  value       = module.database.db_endpoint
}

output "db_port" {
  description = "Port of the RDS instance"
  value       = module.database.db_port
}

output "s3_bucket_id" {
  description = "ID of the S3 bucket"
  value       = module.storage.bucket_id
}

output "kms_key_arn" {
  description = "ARN of the KMS key"
  value       = module.security.kms_key_arn
}
