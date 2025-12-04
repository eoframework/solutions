#------------------------------------------------------------------------------
# Monitoring Module Outputs (Solution-Level)
#------------------------------------------------------------------------------
# Outputs reference the aws/cloudwatch provider module outputs
#------------------------------------------------------------------------------

output "sns_topic_arn" {
  description = "SNS topic ARN for alerts"
  value       = module.cloudwatch.sns_topic_arn
}

output "sns_topic_name" {
  description = "SNS topic name"
  value       = module.cloudwatch.sns_topic_name
}

output "log_group_name" {
  description = "CloudWatch log group name"
  value       = module.cloudwatch.log_group_name
}

output "log_group_arn" {
  description = "CloudWatch log group ARN"
  value       = module.cloudwatch.log_group_arn
}

output "dashboard_arn" {
  description = "CloudWatch dashboard ARN"
  value       = module.cloudwatch.dashboard_arn
}

output "dashboard_url" {
  description = "CloudWatch dashboard URL"
  value       = var.monitoring.enable_dashboard ? "https://${data.aws_region.current.name}.console.aws.amazon.com/cloudwatch/home?region=${data.aws_region.current.name}#dashboards:name=${var.name_prefix}-dashboard" : null
}

output "dashboard_name" {
  description = "CloudWatch dashboard name"
  value       = var.monitoring.enable_dashboard ? "${var.name_prefix}-dashboard" : null
}
