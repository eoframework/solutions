#------------------------------------------------------------------------------
# Integrations Module Outputs
#------------------------------------------------------------------------------

output "waf_association_id" {
  description = "WAF to ALB association ID"
  value       = var.enable_waf && var.alb_arn != "" ? aws_wafv2_web_acl_association.alb[0].id : null
}

output "eks_cpu_alarm_arn" {
  description = "EKS CPU alarm ARN"
  value       = var.enable_alarms && var.eks_cluster_name != "" ? aws_cloudwatch_metric_alarm.eks_cpu[0].arn : null
}

output "rds_cpu_alarm_arn" {
  description = "RDS CPU alarm ARN"
  value       = var.enable_alarms && var.rds_identifier != "" ? aws_cloudwatch_metric_alarm.rds_cpu[0].arn : null
}

output "alarm_count" {
  description = "Number of alarms created"
  value = sum([
    var.enable_alarms && var.eks_cluster_name != "" ? 2 : 0,
    var.enable_alarms && var.rds_identifier != "" ? 3 : 0
  ])
}
