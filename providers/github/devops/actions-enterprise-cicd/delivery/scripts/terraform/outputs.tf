# GitHub Actions Enterprise CI/CD Platform - Terraform Outputs
# This file defines the outputs from the Terraform deployment
# that will be used by other scripts and for reference

# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.github_actions.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.github_actions.cidr_block
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.github_actions.id
}

output "nat_gateway_ids" {
  description = "IDs of the NAT Gateways"
  value       = aws_nat_gateway.github_actions[*].id
}

# Security Group Outputs
output "runner_security_group_id" {
  description = "ID of the runner security group"
  value       = aws_security_group.runner.id
}

output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb.id
}

# IAM Outputs
output "runner_role_arn" {
  description = "ARN of the runner IAM role"
  value       = aws_iam_role.runner.arn
}

output "runner_role_name" {
  description = "Name of the runner IAM role"
  value       = aws_iam_role.runner.name
}

output "runner_instance_profile_arn" {
  description = "ARN of the runner instance profile"
  value       = aws_iam_instance_profile.runner.arn
}

output "runner_instance_profile_name" {
  description = "Name of the runner instance profile"
  value       = aws_iam_instance_profile.runner.name
}

# Launch Template Outputs
output "runner_launch_template_id" {
  description = "ID of the runner launch template"
  value       = aws_launch_template.runner.id
}

output "runner_launch_template_latest_version" {
  description = "Latest version of the runner launch template"
  value       = aws_launch_template.runner.latest_version
}

# Auto Scaling Group Outputs
output "runner_asg_name" {
  description = "Name of the runner Auto Scaling Group"
  value       = aws_autoscaling_group.runner.name
}

output "runner_asg_arn" {
  description = "ARN of the runner Auto Scaling Group"
  value       = aws_autoscaling_group.runner.arn
}

output "runner_asg_min_size" {
  description = "Minimum size of the runner Auto Scaling Group"
  value       = aws_autoscaling_group.runner.min_size
}

output "runner_asg_max_size" {
  description = "Maximum size of the runner Auto Scaling Group"
  value       = aws_autoscaling_group.runner.max_size
}

output "runner_asg_desired_capacity" {
  description = "Desired capacity of the runner Auto Scaling Group"
  value       = aws_autoscaling_group.runner.desired_capacity
}

# S3 Outputs
output "artifacts_bucket_name" {
  description = "Name of the artifacts S3 bucket"
  value       = aws_s3_bucket.artifacts.id
}

output "artifacts_bucket_arn" {
  description = "ARN of the artifacts S3 bucket"
  value       = aws_s3_bucket.artifacts.arn
}

output "artifacts_bucket_domain_name" {
  description = "Bucket domain name of the artifacts S3 bucket"
  value       = aws_s3_bucket.artifacts.bucket_domain_name
}

output "cache_bucket_name" {
  description = "Name of the cache S3 bucket"
  value       = aws_s3_bucket.cache.id
}

output "cache_bucket_arn" {
  description = "ARN of the cache S3 bucket"
  value       = aws_s3_bucket.cache.arn
}

# CloudWatch Outputs
output "log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.runner.name
}

output "log_group_arn" {
  description = "ARN of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.runner.arn
}

# Load Balancer Outputs (if enabled)
output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = var.enable_load_balancer ? aws_lb.github_actions[0].arn : null
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = var.enable_load_balancer ? aws_lb.github_actions[0].dns_name : null
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value       = var.enable_load_balancer ? aws_lb.github_actions[0].zone_id : null
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = var.enable_load_balancer ? aws_lb_target_group.runner[0].arn : null
}

# KMS Outputs
output "kms_key_id" {
  description = "ID of the KMS key for encryption"
  value       = aws_kms_key.github_actions.key_id
}

output "kms_key_arn" {
  description = "ARN of the KMS key for encryption"
  value       = aws_kms_key.github_actions.arn
}

output "kms_alias_name" {
  description = "Name of the KMS alias"
  value       = aws_kms_alias.github_actions.name
}

# SSM Parameter Outputs
output "runner_token_parameter_name" {
  description = "Name of the SSM parameter storing the runner token"
  value       = aws_ssm_parameter.runner_token.name
}

output "github_app_id_parameter_name" {
  description = "Name of the SSM parameter storing the GitHub App ID"
  value       = var.github_app_id != "" ? aws_ssm_parameter.github_app_id[0].name : null
}

output "github_app_private_key_parameter_name" {
  description = "Name of the SSM parameter storing the GitHub App private key"
  value       = var.github_app_private_key != "" ? aws_ssm_parameter.github_app_private_key[0].name : null
}

# SNS Outputs
output "sns_topic_arn" {
  description = "ARN of the SNS topic for notifications"
  value       = aws_sns_topic.notifications.arn
}

output "sns_topic_name" {
  description = "Name of the SNS topic for notifications"
  value       = aws_sns_topic.notifications.name
}

# Lambda Outputs (if webhook is enabled)
output "webhook_lambda_function_name" {
  description = "Name of the webhook Lambda function"
  value       = var.enable_webhook ? aws_lambda_function.webhook[0].function_name : null
}

output "webhook_lambda_function_arn" {
  description = "ARN of the webhook Lambda function"
  value       = var.enable_webhook ? aws_lambda_function.webhook[0].arn : null
}

output "webhook_api_gateway_url" {
  description = "URL of the webhook API Gateway"
  value       = var.enable_webhook ? aws_api_gateway_deployment.webhook[0].invoke_url : null
}

# Route53 Outputs (if custom domain is used)
output "route53_zone_id" {
  description = "Route53 hosted zone ID"
  value       = var.domain_name != "" ? data.aws_route53_zone.main[0].zone_id : null
}

output "route53_record_name" {
  description = "Route53 record name"
  value       = var.domain_name != "" ? aws_route53_record.github_actions[0].name : null
}

# Application Outputs
output "github_organization" {
  description = "GitHub organization name"
  value       = var.github_organization
}

output "project_name" {
  description = "Project name"
  value       = var.project_name
}

output "environment" {
  description = "Environment name"
  value       = var.environment
}

output "aws_region" {
  description = "AWS region"
  value       = var.aws_region
}

# Resource Tags
output "common_tags" {
  description = "Common tags applied to all resources"
  value       = local.common_tags
}

# Monitoring and Observability Outputs
output "cloudwatch_dashboard_url" {
  description = "URL to the CloudWatch dashboard"
  value       = "https://console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${var.project_name}-${var.environment}"
}

output "cloudwatch_logs_insights_url" {
  description = "URL to CloudWatch Logs Insights for runner logs"
  value       = "https://console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#logsV2:logs-insights$3FqueryDetail$3D~(end~0~start~-3600~timeType~'RELATIVE~unit~'seconds~editorString~'fields*20*40timestamp*2c*20*40message*0a*7c*20filter*20*40message*20like*20*2fERROR*2f*0a*7c*20sort*20*40timestamp*20desc*0a*7c*20limit*2020~isLiveTail~false~queryId~'~source~(~'${aws_cloudwatch_log_group.runner.name}))"
}

output "ec2_instances_url" {
  description = "URL to view EC2 instances in AWS console"
  value       = "https://console.aws.amazon.com/ec2/v2/home?region=${var.aws_region}#Instances:tag:aws:autoscaling:groupName=${aws_autoscaling_group.runner.name};sort=instanceId"
}

output "auto_scaling_group_url" {
  description = "URL to view Auto Scaling Group in AWS console"
  value       = "https://console.aws.amazon.com/ec2/autoscaling/home?region=${var.aws_region}#AutoScalingGroups:id=${aws_autoscaling_group.runner.name}"
}

# Security Information
output "runner_security_groups" {
  description = "Security groups attached to runners"
  value = [
    aws_security_group.runner.id
  ]
}

output "runner_subnets" {
  description = "Subnets where runners are deployed"
  value = aws_subnet.private[*].id
}

# Cost Information
output "estimated_monthly_cost" {
  description = "Estimated monthly cost breakdown (approximate)"
  value = {
    ec2_instances = "EC2 instances: $${var.runner_desired_capacity * 0.0464 * 24 * 30} (${var.runner_instance_type})"
    nat_gateways  = "NAT Gateways: $${length(var.availability_zones) * 45.00}"
    s3_storage    = "S3 Storage: Variable based on usage"
    data_transfer = "Data Transfer: Variable based on usage"
    cloudwatch    = "CloudWatch: ~$10-30/month"
    note          = "Costs are estimates and may vary based on actual usage"
  }
}

# Operational Information
output "operational_info" {
  description = "Important operational information"
  value = {
    runner_ami_id           = data.aws_ami.runner.id
    runner_instance_type    = var.runner_instance_type
    availability_zones      = var.availability_zones
    backup_retention_days   = var.backup_retention_days
    log_retention_days      = var.log_retention_days
    enable_detailed_monitoring = var.enable_detailed_monitoring
    enable_encryption       = var.enable_encryption
  }
}

# Next Steps Information
output "next_steps" {
  description = "Next steps after deployment"
  value = [
    "1. Verify runners are connecting to GitHub Actions",
    "2. Test workflow execution with a sample repository",
    "3. Configure additional organization secrets as needed",
    "4. Set up monitoring alerts and notifications",
    "5. Review and adjust auto-scaling policies",
    "6. Configure backup and disaster recovery procedures",
    "7. Train development teams on the new platform"
  ]
}

# Troubleshooting Information
output "troubleshooting_commands" {
  description = "Common troubleshooting commands"
  value = {
    check_runner_logs        = "aws logs tail ${aws_cloudwatch_log_group.runner.name} --follow --region ${var.aws_region}"
    check_asg_activity      = "aws autoscaling describe-scaling-activities --auto-scaling-group-name ${aws_autoscaling_group.runner.name} --region ${var.aws_region}"
    check_instance_health   = "aws ec2 describe-instances --filters 'Name=tag:aws:autoscaling:groupName,Values=${aws_autoscaling_group.runner.name}' --region ${var.aws_region}"
    ssh_to_instance        = "aws ssm start-session --target <instance-id> --region ${var.aws_region}"
    view_metrics           = "aws cloudwatch get-metric-statistics --namespace AWS/EC2 --metric-name CPUUtilization --dimensions Name=AutoScalingGroupName,Value=${aws_autoscaling_group.runner.name} --start-time $(date -u -d '1 hour ago' '+%Y-%m-%dT%H:%M:%S') --end-time $(date -u '+%Y-%m-%dT%H:%M:%S') --period 300 --statistics Average --region ${var.aws_region}"
  }
}