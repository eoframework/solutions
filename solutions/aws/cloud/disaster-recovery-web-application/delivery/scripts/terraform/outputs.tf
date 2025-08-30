# AWS Disaster Recovery Web Application - Outputs

output "primary_vpc_id" {
  description = "ID of the primary VPC"
  value       = module.primary_vpc.vpc_id
}

output "secondary_vpc_id" {
  description = "ID of the secondary (DR) VPC"
  value       = module.secondary_vpc.vpc_id
}

output "primary_alb_dns" {
  description = "DNS name of the primary Application Load Balancer"
  value       = aws_lb.primary.dns_name
}

output "secondary_alb_dns" {
  description = "DNS name of the secondary (DR) Application Load Balancer"
  value       = aws_lb.secondary.dns_name
}

output "primary_rds_endpoint" {
  description = "RDS instance endpoint in primary region"
  value       = aws_db_instance.primary.endpoint
}

output "secondary_rds_endpoint" {
  description = "RDS read replica endpoint in secondary region"
  value       = aws_db_instance.secondary.endpoint
}

output "route53_zone_id" {
  description = "Route 53 hosted zone ID"
  value       = aws_route53_zone.main.zone_id
}

output "route53_zone_name" {
  description = "Route 53 hosted zone name"
  value       = aws_route53_zone.main.name
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = aws_cloudfront_distribution.main.id
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name"
  value       = aws_cloudfront_distribution.main.domain_name
}

output "s3_primary_bucket" {
  description = "Primary S3 bucket name"
  value       = aws_s3_bucket.primary.bucket
}

output "s3_secondary_bucket" {
  description = "Secondary (DR) S3 bucket name"
  value       = aws_s3_bucket.secondary.bucket
}

output "primary_auto_scaling_group_name" {
  description = "Primary Auto Scaling Group name"
  value       = aws_autoscaling_group.primary.name
}

output "secondary_auto_scaling_group_name" {
  description = "Secondary Auto Scaling Group name"
  value       = aws_autoscaling_group.secondary.name
}

output "backup_vault_name" {
  description = "AWS Backup vault name"
  value       = aws_backup_vault.main.name
}

output "kms_key_id" {
  description = "KMS key ID for encryption"
  value       = aws_kms_key.main.key_id
}

output "sns_topic_arn" {
  description = "SNS topic ARN for notifications"
  value       = aws_sns_topic.alerts.arn
}

output "cloudwatch_log_group" {
  description = "CloudWatch log group name"
  value       = aws_cloudwatch_log_group.app_logs.name
}

output "project_name" {
  description = "Project name used for resource naming"
  value       = var.project_name
}

output "environment" {
  description = "Environment name"
  value       = var.environment
}

output "primary_region" {
  description = "Primary AWS region"
  value       = var.primary_region
}

output "secondary_region" {
  description = "Secondary (DR) AWS region"
  value       = var.secondary_region
}