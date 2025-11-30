# Solution Monitoring Module - Outputs
# Outputs from generic CloudWatch module

output "sns_topic_arn" {
  description = "SNS topic ARN for alarms"
  value       = module.cloudwatch.sns_topic_arn
}

output "application_log_group_name" {
  description = "Application log group name"
  value       = module.cloudwatch.log_group_names["application"]
}

output "application_log_group_arn" {
  description = "Application log group ARN"
  value       = module.cloudwatch.log_group_arns["application"]
}

output "ecs_log_group_name" {
  description = "ECS log group name"
  value       = var.monitoring.enable_container_insights ? module.cloudwatch.log_group_names["ecs"] : null
}

output "dashboard_name" {
  description = "CloudWatch dashboard name"
  value       = var.monitoring.enable_dashboard ? "${var.name_prefix}-dashboard" : null
}

output "dashboard_arn" {
  description = "CloudWatch dashboard ARN"
  value       = var.monitoring.enable_dashboard ? module.cloudwatch.dashboard_arn : null
}
