# AWS Monitoring Module - Outputs

output "cloudwatch_log_groups" {
  description = "CloudWatch log groups created"
  value = {
    application_logs = aws_cloudwatch_log_group.application_logs.name
    system_logs      = aws_cloudwatch_log_group.system_logs.name
  }
}

output "dashboard_url" {
  description = "CloudWatch dashboard URL"
  value       = "https://${var.region}.console.aws.amazon.com/cloudwatch/home?region=${var.region}#dashboards:name=${aws_cloudwatch_dashboard.main.dashboard_name}"
}

output "cloudtrail_arn" {
  description = "CloudTrail ARN"
  value       = aws_cloudtrail.main.arn
}

output "cloudtrail_bucket" {
  description = "S3 bucket for CloudTrail logs"
  value       = aws_s3_bucket.cloudtrail.id
}

output "sns_topic_arn" {
  description = "SNS topic ARN for alerts"
  value       = length(aws_sns_topic.alerts) > 0 ? aws_sns_topic.alerts[0].arn : null
}

output "alarms" {
  description = "CloudWatch alarms created"
  value = {
    high_cpu           = aws_cloudwatch_metric_alarm.high_cpu.arn
    high_response_time = aws_cloudwatch_metric_alarm.high_response_time.arn
  }
}