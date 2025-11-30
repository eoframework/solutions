# Solution Security Module - Outputs
# Outputs from generic KMS and WAF modules

#------------------------------------------------------------------------------
# KMS Outputs (from generic KMS module)
#------------------------------------------------------------------------------

output "kms_key_arn" {
  description = "KMS key ARN"
  value       = var.security.enable_kms_encryption ? module.kms[0].key_arn : null
}

output "kms_key_id" {
  description = "KMS key ID"
  value       = var.security.enable_kms_encryption ? module.kms[0].key_id : null
}

output "kms_alias_arn" {
  description = "KMS alias ARN"
  value       = var.security.enable_kms_encryption ? module.kms[0].alias_arn : null
}

#------------------------------------------------------------------------------
# WAF Outputs (from generic WAF module)
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
  value       = var.security.enable_guardduty ? aws_guardduty_detector.main[0].id : null
}

#------------------------------------------------------------------------------
# CloudTrail Outputs
#------------------------------------------------------------------------------

output "cloudtrail_arn" {
  description = "CloudTrail ARN"
  value       = var.security.enable_cloudtrail ? aws_cloudtrail.main[0].arn : null
}

output "cloudtrail_bucket_name" {
  description = "CloudTrail S3 bucket name"
  value       = var.security.enable_cloudtrail ? aws_s3_bucket.cloudtrail[0].id : null
}
