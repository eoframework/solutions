#------------------------------------------------------------------------------
# Security Module (Solution-Level)
#------------------------------------------------------------------------------
# Composes aws/kms, aws/waf, aws/guardduty, aws/cloudtrail provider modules
# for Terraform Enterprise security infrastructure
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# KMS Module
#------------------------------------------------------------------------------
module "kms" {
  source = "../../aws/kms"
  count  = var.security.enable_kms_encryption ? 1 : 0

  name_prefix             = var.name_prefix
  common_tags             = var.common_tags
  description             = "${var.name_prefix} encryption key"
  deletion_window_in_days = var.security.kms_deletion_window
  enable_key_rotation     = true

  # Service permissions for TFE
  enable_cloudwatch_logs = true
  enable_sns             = true
  enable_s3              = true
  enable_rds             = true
  enable_eks             = false
}

#------------------------------------------------------------------------------
# WAF Module
#------------------------------------------------------------------------------
module "waf" {
  source = "../../aws/waf"
  count  = var.security.enable_waf ? 1 : 0

  name_prefix = var.name_prefix
  common_tags = var.common_tags
  description = "WAF for ${var.name_prefix}"
  scope       = "REGIONAL"

  # Rule configuration
  enable_common_rules     = true
  enable_rate_limiting    = true
  rate_limit              = var.security.waf_rate_limit
  enable_bad_inputs_rules = true
  enable_sqli_rules       = true
}

#------------------------------------------------------------------------------
# GuardDuty Module
#------------------------------------------------------------------------------
module "guardduty" {
  source = "../../aws/guardduty"
  count  = var.security.enable_guardduty ? 1 : 0

  name_prefix = var.name_prefix
  common_tags = var.common_tags
  enabled     = true

  # Data sources
  enable_s3_logs               = true
  enable_kubernetes_audit_logs = true
  enable_malware_protection    = true
}

#------------------------------------------------------------------------------
# CloudTrail Module
#------------------------------------------------------------------------------
module "cloudtrail" {
  source = "../../aws/cloudtrail"
  count  = var.security.enable_cloudtrail ? 1 : 0

  name_prefix = var.name_prefix
  common_tags = var.common_tags

  # Use KMS encryption if enabled
  kms_key_arn = var.security.enable_kms_encryption ? module.kms[0].key_arn : ""

  # Trail configuration
  include_global_service_events = true
  is_multi_region_trail         = true
  retention_days                = 365
  transition_to_glacier_days    = 90
}
