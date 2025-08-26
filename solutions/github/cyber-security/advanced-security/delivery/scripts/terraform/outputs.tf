# GitHub Advanced Security Platform - Terraform Outputs
# This file defines the outputs from the Terraform deployment
# for security monitoring infrastructure and integrations

# VPC Outputs
output "vpc_id" {
  description = "ID of the security monitoring VPC"
  value       = aws_vpc.security_monitoring.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the security monitoring VPC"
  value       = aws_vpc.security_monitoring.cidr_block
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
  value       = aws_internet_gateway.security_monitoring.id
}

output "nat_gateway_ids" {
  description = "IDs of the NAT Gateways"
  value       = aws_nat_gateway.security_monitoring[*].id
}

# Security Group Outputs
output "security_monitoring_sg_id" {
  description = "ID of the security monitoring security group"
  value       = aws_security_group.security_monitoring.id
}

# IAM Outputs
output "security_monitoring_role_arn" {
  description = "ARN of the security monitoring IAM role"
  value       = aws_iam_role.security_monitoring.arn
}

output "security_monitoring_role_name" {
  description = "Name of the security monitoring IAM role"
  value       = aws_iam_role.security_monitoring.name
}

# S3 Outputs
output "security_logs_bucket_name" {
  description = "Name of the security logs S3 bucket"
  value       = aws_s3_bucket.security_logs.id
}

output "security_logs_bucket_arn" {
  description = "ARN of the security logs S3 bucket"
  value       = aws_s3_bucket.security_logs.arn
}

output "security_logs_bucket_domain_name" {
  description = "Bucket domain name of the security logs S3 bucket"
  value       = aws_s3_bucket.security_logs.bucket_domain_name
}

# CloudWatch Outputs
output "log_group_name" {
  description = "Name of the CloudWatch log group for security monitoring"
  value       = aws_cloudwatch_log_group.security_monitoring.name
}

output "log_group_arn" {
  description = "ARN of the CloudWatch log group for security monitoring"
  value       = aws_cloudwatch_log_group.security_monitoring.arn
}

# KMS Outputs
output "kms_key_id" {
  description = "ID of the KMS key for security monitoring encryption"
  value       = aws_kms_key.security_monitoring.key_id
}

output "kms_key_arn" {
  description = "ARN of the KMS key for security monitoring encryption"
  value       = aws_kms_key.security_monitoring.arn
}

output "kms_alias_name" {
  description = "Name of the KMS alias"
  value       = aws_kms_alias.security_monitoring.name
}

# SNS Outputs
output "security_alerts_topic_arn" {
  description = "ARN of the SNS topic for security alerts"
  value       = aws_sns_topic.security_alerts.arn
}

output "security_alerts_topic_name" {
  description = "Name of the SNS topic for security alerts"
  value       = aws_sns_topic.security_alerts.name
}

# Lambda Outputs (if webhook is enabled)
output "security_webhook_function_name" {
  description = "Name of the security webhook Lambda function"
  value       = var.enable_webhook ? aws_lambda_function.security_webhook[0].function_name : null
}

output "security_webhook_function_arn" {
  description = "ARN of the security webhook Lambda function"
  value       = var.enable_webhook ? aws_lambda_function.security_webhook[0].arn : null
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

# Security Configuration Outputs
output "security_configuration" {
  description = "Summary of security configuration settings"
  value = {
    encryption_enabled        = var.enable_encryption
    codeql_enabled           = var.enable_codeql
    secret_scanning_enabled  = var.enable_secret_scanning
    dependency_scanning_enabled = var.enable_dependency_scanning
    webhook_enabled          = var.enable_webhook
    audit_logging_enabled    = var.enable_audit_logging
    backup_enabled           = var.enable_backup
  }
}

# Monitoring and Observability Outputs
output "cloudwatch_dashboard_url" {
  description = "URL to the CloudWatch dashboard"
  value       = var.enable_dashboard ? "https://console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${var.dashboard_name != "" ? var.dashboard_name : "${var.project_name}-${var.environment}-security"}" : null
}

output "cloudwatch_logs_insights_url" {
  description = "URL to CloudWatch Logs Insights for security logs"
  value       = "https://console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#logsV2:logs-insights$3FqueryDetail$3D~(end~0~start~-3600~timeType~'RELATIVE~unit~'seconds~editorString~'fields*20*40timestamp*2c*20*40message*0a*7c*20filter*20*40message*20like*20*2fSECURITY*2f*0a*7c*20sort*20*40timestamp*20desc*0a*7c*20limit*2020~isLiveTail~false~queryId~'~source~(~'${aws_cloudwatch_log_group.security_monitoring.name}))"
}

output "s3_security_logs_url" {
  description = "URL to view security logs in S3 console"
  value       = "https://console.aws.amazon.com/s3/buckets/${aws_s3_bucket.security_logs.bucket}?region=${var.aws_region}"
}

# SIEM Integration Information
output "siem_integration_info" {
  description = "Information for SIEM integration"
  value = {
    splunk_enabled    = var.enable_splunk_integration
    sentinel_enabled  = var.enable_azure_sentinel
    datadog_enabled   = var.datadog_api_key != ""
    s3_logs_bucket   = aws_s3_bucket.security_logs.bucket
    cloudwatch_log_group = aws_cloudwatch_log_group.security_monitoring.name
    sns_topic_arn    = aws_sns_topic.security_alerts.arn
  }
}

# Compliance Information
output "compliance_info" {
  description = "Compliance monitoring configuration"
  value = {
    frameworks_monitored = var.compliance_frameworks
    audit_log_retention  = var.audit_log_retention_days
    backup_retention     = var.backup_retention_days
    encryption_enabled   = var.enable_encryption
    detailed_monitoring  = var.enable_detailed_monitoring
  }
}

# Cost Information
output "estimated_monthly_cost" {
  description = "Estimated monthly cost breakdown (approximate)"
  value = {
    ec2_instances = var.auto_scaling_desired_capacity > 0 ? "EC2 instances: $${var.auto_scaling_desired_capacity * 25.00}/month (${var.security_monitoring_instance_type})" : "No EC2 instances configured"
    nat_gateways  = "NAT Gateways: $${length(var.availability_zones) * 45.00}/month"
    s3_storage    = "S3 Storage: Variable based on security log volume"
    lambda        = var.enable_webhook ? "Lambda: ~$5-15/month based on invocations" : "Lambda: Not enabled"
    cloudwatch    = "CloudWatch: ~$20-50/month for logs and metrics"
    data_transfer = "Data Transfer: Variable based on SIEM integration"
    kms          = "KMS: ~$1/month for key + $0.03 per 10,000 requests"
    note         = "Costs are estimates and may vary based on actual usage and security event volume"
  }
}

# Operational Information
output "operational_info" {
  description = "Important operational information for security monitoring"
  value = {
    log_retention_days       = var.log_retention_days
    audit_log_retention_days = var.audit_log_retention_days
    backup_retention_days    = var.backup_retention_days
    security_scan_schedule   = var.security_scan_schedule
    notification_email       = var.notification_email != "" ? var.notification_email : "Not configured"
    webhook_enabled          = var.enable_webhook
    dashboard_enabled        = var.enable_dashboard
    alarms_enabled          = var.enable_alarms
  }
}

# Security Baseline Information
output "security_baseline" {
  description = "Security baseline configuration applied"
  value       = var.security_baseline_config
}

# Next Steps Information
output "next_steps" {
  description = "Next steps after infrastructure deployment"
  value = [
    "1. Configure GitHub organization security settings",
    "2. Enable GitHub Advanced Security features for repositories",
    "3. Set up SIEM integration endpoints and authentication",
    "4. Configure security alert routing and escalation procedures",
    "5. Train security team on new monitoring capabilities",
    "6. Establish incident response procedures",
    "7. Configure compliance reporting schedules",
    "8. Test security alert workflows end-to-end",
    "9. Set up regular security posture assessments",
    "10. Configure backup and disaster recovery procedures"
  ]
}

# Troubleshooting Information
output "troubleshooting_commands" {
  description = "Common troubleshooting commands for security monitoring"
  value = {
    check_security_logs     = "aws logs tail ${aws_cloudwatch_log_group.security_monitoring.name} --follow --region ${var.aws_region}"
    check_webhook_logs      = var.enable_webhook ? "aws logs tail /aws/lambda/${aws_lambda_function.security_webhook[0].function_name} --follow --region ${var.aws_region}" : "Webhook not enabled"
    list_s3_security_logs   = "aws s3 ls s3://${aws_s3_bucket.security_logs.bucket}/ --recursive --region ${var.aws_region}"
    check_sns_subscriptions = "aws sns list-subscriptions-by-topic --topic-arn ${aws_sns_topic.security_alerts.arn} --region ${var.aws_region}"
    test_kms_encryption     = "aws kms describe-key --key-id ${aws_kms_key.security_monitoring.key_id} --region ${var.aws_region}"
    check_security_groups   = "aws ec2 describe-security-groups --group-ids ${aws_security_group.security_monitoring.id} --region ${var.aws_region}"
  }
}

# GitHub API Information
output "github_api_info" {
  description = "Information for GitHub API integration"
  value = {
    organization     = var.github_organization
    app_id_configured = var.github_app_id != ""
    webhook_endpoint  = var.enable_webhook ? "Configure webhook URL after API Gateway deployment" : "Webhook not enabled"
    required_scopes   = [
      "repo",
      "admin:org",
      "admin:repo_hook",
      "security_events",
      "metadata"
    ]
  }
}

# Security Scanning Configuration
output "security_scanning_config" {
  description = "Security scanning configuration summary"
  value = {
    codeql_enabled           = var.enable_codeql
    secret_scanning_enabled  = var.enable_secret_scanning
    dependency_scanning_enabled = var.enable_dependency_scanning
    scan_schedule           = var.security_scan_schedule
    custom_rules_count      = length(var.custom_security_rules)
  }
}

# Integration Endpoints
output "integration_endpoints" {
  description = "Endpoints for external system integrations"
  value = {
    webhook_url = var.enable_webhook ? "Will be available after API Gateway deployment" : null
    s3_logs_bucket = aws_s3_bucket.security_logs.bucket
    sns_topic_arn = aws_sns_topic.security_alerts.arn
    cloudwatch_log_group = aws_cloudwatch_log_group.security_monitoring.name
    kms_key_arn = aws_kms_key.security_monitoring.arn
  }
}