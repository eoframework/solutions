#------------------------------------------------------------------------------
# Security Module Outputs (Solution-Level)
#------------------------------------------------------------------------------
# Outputs reference the aws/kms, aws/waf, aws/guardduty, aws/cloudtrail
# provider module outputs
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# KMS Outputs
#------------------------------------------------------------------------------
output "kms_key_arn" {
  description = "KMS key ARN"
  value       = var.security.enable_kms_encryption ? module.kms[0].key_arn : null
}

output "kms_key_id" {
  description = "KMS key ID"
  value       = var.security.enable_kms_encryption ? module.kms[0].key_id : null
}

output "kms_alias_name" {
  description = "KMS key alias name"
  value       = var.security.enable_kms_encryption ? module.kms[0].alias_name : null
}

#------------------------------------------------------------------------------
# WAF Outputs
#------------------------------------------------------------------------------
output "waf_web_acl_arn" {
  description = "WAF Web ACL ARN"
  value       = var.security.enable_waf ? module.waf[0].web_acl_arn : null
}

output "waf_web_acl_id" {
  description = "WAF Web ACL ID"
  value       = var.security.enable_waf ? module.waf[0].web_acl_id : null
}

#------------------------------------------------------------------------------
# GuardDuty Outputs
#------------------------------------------------------------------------------
output "guardduty_detector_id" {
  description = "GuardDuty detector ID"
  value       = var.security.enable_guardduty ? module.guardduty[0].detector_id : null
}

#------------------------------------------------------------------------------
# CloudTrail Outputs
#------------------------------------------------------------------------------
output "cloudtrail_arn" {
  description = "CloudTrail ARN"
  value       = var.security.enable_cloudtrail ? module.cloudtrail[0].cloudtrail_arn : null
}

output "cloudtrail_bucket_name" {
  description = "CloudTrail S3 bucket name"
  value       = var.security.enable_cloudtrail ? module.cloudtrail[0].bucket_name : null
}

output "cloudtrail_bucket_arn" {
  description = "CloudTrail S3 bucket ARN"
  value       = var.security.enable_cloudtrail ? module.cloudtrail[0].bucket_arn : null
}
