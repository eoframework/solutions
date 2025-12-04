#------------------------------------------------------------------------------
# Security Module (Solution-Level)
#------------------------------------------------------------------------------
# Composes aws/kms, aws/waf, aws/guardduty provider modules
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# KMS (uses aws/kms provider module)
#------------------------------------------------------------------------------
module "kms" {
  source = "../../aws/kms"
  count  = var.security.enable_kms_encryption ? 1 : 0

  name_prefix             = var.name_prefix
  common_tags             = var.common_tags
  description             = "KMS key for ${var.name_prefix} encryption"
  deletion_window_in_days = var.security.kms_deletion_window
  enable_key_rotation     = true

  # Enable service permissions for HashiCorp platform
  enable_cloudwatch_logs = true
  enable_sns             = true
  enable_s3              = true
  enable_rds             = true
  enable_eks             = true
}

#------------------------------------------------------------------------------
# WAF (uses aws/waf provider module)
#------------------------------------------------------------------------------
module "waf" {
  source = "../../aws/waf"
  count  = var.security.enable_waf ? 1 : 0

  name_prefix         = var.name_prefix
  common_tags         = var.common_tags
  description         = "WAF for ${var.name_prefix}"
  scope               = "REGIONAL"
  default_action      = "allow"

  # Enable managed rules
  enable_common_rules     = true
  enable_rate_limiting    = true
  rate_limit              = var.security.waf_rate_limit
  enable_bad_inputs_rules = true
  enable_sqli_rules       = true

  # Metrics and logging
  enable_cloudwatch_metrics = true
  enable_sampled_requests   = true
}

#------------------------------------------------------------------------------
# GuardDuty (uses aws/guardduty provider module)
#------------------------------------------------------------------------------
module "guardduty" {
  source = "../../aws/guardduty"
  count  = var.security.enable_guardduty ? 1 : 0

  name_prefix                  = var.name_prefix
  common_tags                  = var.common_tags
  enabled                      = true
  enable_s3_logs               = true
  enable_kubernetes_audit_logs = true
  enable_malware_protection    = true
  finding_publishing_frequency = "FIFTEEN_MINUTES"
}
