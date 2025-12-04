#------------------------------------------------------------------------------
# Integrations Module Outputs
#------------------------------------------------------------------------------

output "waf_association_id" {
  description = "WAF to ALB association ID"
  value       = var.enable_waf && var.alb_arn != "" ? aws_wafv2_web_acl_association.alb[0].id : ""
}

output "vault_aws_backend_path" {
  description = "Vault AWS secrets engine path"
  value       = var.vault_enabled && var.vault_aws_secrets_enabled ? vault_aws_secret_backend.aws[0].path : ""
}

output "eks_cpu_alarm_arn" {
  description = "EKS CPU alarm ARN"
  value       = var.enable_alarms && var.eks_cluster_name != "" ? aws_cloudwatch_metric_alarm.eks_cpu[0].arn : ""
}

output "rds_cpu_alarm_arn" {
  description = "RDS CPU alarm ARN"
  value       = var.enable_alarms && var.rds_identifier != "" ? aws_cloudwatch_metric_alarm.rds_cpu[0].arn : ""
}

output "rds_storage_alarm_arn" {
  description = "RDS storage alarm ARN"
  value       = var.enable_alarms && var.rds_identifier != "" ? aws_cloudwatch_metric_alarm.rds_storage[0].arn : ""
}
