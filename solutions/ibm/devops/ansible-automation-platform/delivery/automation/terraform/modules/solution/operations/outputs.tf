#------------------------------------------------------------------------------
# AAP Operations Module - Outputs
#------------------------------------------------------------------------------

output "sns_topic_arn" {
  description = "SNS topic ARN for alerts"
  value       = var.monitoring.create_sns_topic ? aws_sns_topic.aap_alerts[0].arn : var.monitoring.sns_topic_arn
}

output "controller_log_group_name" {
  description = "CloudWatch log group name for controller logs"
  value       = aws_cloudwatch_log_group.aap_logs.name
}

output "execution_log_group_name" {
  description = "CloudWatch log group name for execution logs"
  value       = aws_cloudwatch_log_group.execution_logs.name
}

output "backup_bucket_name" {
  description = "S3 bucket name for backups"
  value       = var.backup.enabled ? aws_s3_bucket.backups[0].id : ""
}

output "backup_bucket_arn" {
  description = "S3 bucket ARN for backups"
  value       = var.backup.enabled ? aws_s3_bucket.backups[0].arn : ""
}

output "backup_vault_arn" {
  description = "AWS Backup vault ARN"
  value       = var.backup.enabled && var.backup.use_aws_backup ? aws_backup_vault.aap[0].arn : ""
}
