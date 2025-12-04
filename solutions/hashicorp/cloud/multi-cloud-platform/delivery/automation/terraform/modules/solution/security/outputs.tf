#------------------------------------------------------------------------------
# Security Module - Outputs
#------------------------------------------------------------------------------

output "kms_key_arn" {
  description = "KMS key ARN"
  value       = var.security.enable_kms_encryption ? aws_kms_key.main[0].arn : null
}

output "kms_key_id" {
  description = "KMS key ID"
  value       = var.security.enable_kms_encryption ? aws_kms_key.main[0].key_id : null
}

output "waf_web_acl_arn" {
  description = "WAF Web ACL ARN"
  value       = var.security.enable_waf ? aws_wafv2_web_acl.main[0].arn : null
}

output "waf_web_acl_id" {
  description = "WAF Web ACL ID"
  value       = var.security.enable_waf ? aws_wafv2_web_acl.main[0].id : null
}

output "guardduty_detector_id" {
  description = "GuardDuty detector ID"
  value       = var.security.enable_guardduty ? aws_guardduty_detector.main[0].id : null
}
