#------------------------------------------------------------------------------
# DR Web Application Security Module - Outputs
#------------------------------------------------------------------------------

output "kms_key_arn" {
  description = "ARN of the primary KMS key"
  value       = aws_kms_key.primary.arn
}

output "kms_key_id" {
  description = "ID of the primary KMS key"
  value       = aws_kms_key.primary.key_id
}

output "waf_web_acl_arn" {
  description = "ARN of the WAF Web ACL"
  value       = var.security.enable_waf ? aws_wafv2_web_acl.main[0].arn : null
}

output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb.id
}

output "app_security_group_id" {
  description = "ID of the application security group"
  value       = aws_security_group.app.id
}

output "db_security_group_id" {
  description = "ID of the database security group"
  value       = aws_security_group.db.id
}
