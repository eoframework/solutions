#------------------------------------------------------------------------------
# Security Module Outputs (Solution-Level)
#------------------------------------------------------------------------------
# Outputs reference the aws/* provider module outputs
#------------------------------------------------------------------------------

output "kms_key_arn" {
  description = "KMS key ARN"
  value       = var.security.enable_kms_encryption ? module.kms[0].key_arn : null
}

output "kms_key_id" {
  description = "KMS key ID"
  value       = var.security.enable_kms_encryption ? module.kms[0].key_id : null
}

output "waf_web_acl_arn" {
  description = "WAF Web ACL ARN"
  value       = var.security.enable_waf ? module.waf[0].web_acl_arn : null
}

output "waf_web_acl_id" {
  description = "WAF Web ACL ID"
  value       = var.security.enable_waf ? module.waf[0].web_acl_id : null
}

output "guardduty_detector_id" {
  description = "GuardDuty detector ID"
  value       = var.security.enable_guardduty ? module.guardduty[0].detector_id : null
}
