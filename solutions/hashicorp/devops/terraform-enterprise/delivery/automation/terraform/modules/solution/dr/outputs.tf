#------------------------------------------------------------------------------
# DR Module Outputs
#------------------------------------------------------------------------------

output "dr_alerts_topic_arn" {
  description = "DR alerts SNS topic ARN"
  value       = aws_sns_topic.dr_alerts.arn
}

output "dr_status_parameter_name" {
  description = "DR status SSM parameter name"
  value       = aws_ssm_parameter.dr_status.name
}

output "health_check_id" {
  description = "Route 53 health check ID"
  value       = var.dr.enabled ? aws_route53_health_check.primary[0].id : null
}

output "dr_runbook_name" {
  description = "DR runbook SSM document name"
  value       = var.dr.enabled ? aws_ssm_document.dr_runbook[0].name : null
}

output "dr_configuration" {
  description = "DR configuration summary"
  value = {
    enabled       = var.dr.enabled
    strategy      = var.dr.strategy
    rto_minutes   = var.dr.rto_minutes
    rpo_minutes   = var.dr.rpo_minutes
    failover_mode = var.dr.failover_mode
    dr_region     = var.dr_region
  }
}
