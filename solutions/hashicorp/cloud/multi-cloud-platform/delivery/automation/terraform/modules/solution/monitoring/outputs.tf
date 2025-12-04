#------------------------------------------------------------------------------
# Monitoring Module Outputs
#------------------------------------------------------------------------------

output "sns_topic_arn" {
  description = "SNS topic ARN for alerts"
  value       = aws_sns_topic.alerts.arn
}

output "sns_topic_name" {
  description = "SNS topic name"
  value       = aws_sns_topic.alerts.name
}

output "dashboard_arn" {
  description = "CloudWatch dashboard ARN"
  value       = var.monitoring.enable_dashboard ? aws_cloudwatch_dashboard.main[0].dashboard_arn : ""
}

output "application_log_group" {
  description = "Application log group name"
  value       = aws_cloudwatch_log_group.application.name
}

output "platform_log_group" {
  description = "Platform log group name"
  value       = aws_cloudwatch_log_group.platform.name
}
