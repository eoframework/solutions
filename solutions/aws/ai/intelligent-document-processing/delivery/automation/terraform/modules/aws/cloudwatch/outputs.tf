# Generic AWS CloudWatch Module - Outputs

output "log_group_arns" {
  description = "Map of log group ARNs"
  value       = { for k, v in aws_cloudwatch_log_group.this : k => v.arn }
}

output "log_group_names" {
  description = "Map of log group names"
  value       = { for k, v in aws_cloudwatch_log_group.this : k => v.name }
}

output "alarm_arns" {
  description = "Map of alarm ARNs"
  value       = { for k, v in aws_cloudwatch_metric_alarm.this : k => v.arn }
}

output "alarm_names" {
  description = "Map of alarm names"
  value       = { for k, v in aws_cloudwatch_metric_alarm.this : k => v.alarm_name }
}

output "dashboard_arn" {
  description = "Dashboard ARN"
  value       = var.create_dashboard ? aws_cloudwatch_dashboard.this[0].dashboard_arn : null
}

output "sns_topic_arn" {
  description = "SNS topic ARN for alarms"
  value       = var.create_sns_topic ? aws_sns_topic.alarms[0].arn : null
}

output "composite_alarm_arns" {
  description = "Map of composite alarm ARNs"
  value       = { for k, v in aws_cloudwatch_composite_alarm.this : k => v.arn }
}
