#------------------------------------------------------------------------------
# OpenShift Solution - Operations Module Outputs
#------------------------------------------------------------------------------

output "backup_bucket_id" {
  description = "S3 backup bucket ID"
  value       = var.backup.enabled ? module.backup[0].bucket_id : null
}

output "backup_bucket_arn" {
  description = "S3 backup bucket ARN"
  value       = var.backup.enabled ? module.backup[0].bucket_arn : null
}

output "backup_replica_bucket_id" {
  description = "S3 backup replica bucket ID"
  value       = var.backup.enabled && var.dr.enabled ? module.backup[0].replica_bucket_id : null
}

output "sns_topic_arn" {
  description = "SNS topic ARN for alerts"
  value       = var.monitoring.create_sns_topic ? aws_sns_topic.alerts[0].arn : var.monitoring.sns_topic_arn
}

output "etcd_backup_schedule_arn" {
  description = "EventBridge rule ARN for etcd backup"
  value       = var.backup.enabled ? aws_cloudwatch_event_rule.etcd_backup[0].arn : null
}
