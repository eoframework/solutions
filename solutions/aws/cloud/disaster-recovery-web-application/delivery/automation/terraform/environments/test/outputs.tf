#------------------------------------------------------------------------------
# DR Web Application - Test Environment Outputs
#------------------------------------------------------------------------------

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.core.vpc_id
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.core.alb_dns_name
}

output "aurora_cluster_endpoint" {
  description = "Writer endpoint of the Aurora cluster"
  value       = module.database.cluster_endpoint
}

output "s3_bucket_id" {
  description = "ID of the S3 bucket"
  value       = module.storage.bucket_id
}

output "kms_key_arn" {
  description = "ARN of the KMS key"
  value       = module.security.kms_key_arn
}
