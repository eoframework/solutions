#------------------------------------------------------------------------------
# AWS CloudWatch Module Outputs
#------------------------------------------------------------------------------

output "sns_topic_arn" {
  description = "SNS topic ARN for alerts"
  value       = var.create_sns_topic ? aws_sns_topic.alerts[0].arn : ""
}

output "sns_topic_name" {
  description = "SNS topic name"
  value       = var.create_sns_topic ? aws_sns_topic.alerts[0].name : ""
}

output "log_group_name" {
  description = "CloudWatch log group name"
  value       = var.create_log_group ? aws_cloudwatch_log_group.main[0].name : ""
}

output "log_group_arn" {
  description = "CloudWatch log group ARN"
  value       = var.create_log_group ? aws_cloudwatch_log_group.main[0].arn : ""
}

output "dashboard_arn" {
  description = "CloudWatch dashboard ARN"
  value       = var.create_dashboard ? aws_cloudwatch_dashboard.main[0].dashboard_arn : ""
}

output "alarm_arns" {
  description = "Map of alarm names to ARNs"
  value       = { for k, v in aws_cloudwatch_metric_alarm.alarms : k => v.arn }
}
