# Solution Cache Module
# Deploys: ElastiCache Redis cluster with encryption and CloudWatch alarms

locals {
  name_prefix = var.name_prefix
  common_tags = var.common_tags

  # Construct full SSM parameter path from prefix and suffix
  auth_token_param_path = "/${var.name_prefix}/${var.cache.auth_token_param_name}"

  # Only use auth token if transit encryption is enabled
  use_auth_token = var.cache.enabled && var.cache.transit_encryption && var.cache.auth_token_param_name != ""
}

#------------------------------------------------------------------------------
# Retrieve Auth Token from SSM Parameter Store
#------------------------------------------------------------------------------

data "aws_ssm_parameter" "auth_token" {
  count           = local.use_auth_token ? 1 : 0
  name            = local.auth_token_param_path
  with_decryption = true
}

#------------------------------------------------------------------------------
# ElastiCache Redis
#------------------------------------------------------------------------------

module "elasticache" {
  source = "../../aws/elasticache"

  name_prefix        = local.name_prefix
  tags               = local.common_tags
  subnet_group_name  = var.elasticache_subnet_group_name
  security_group_ids = var.security_group_ids
  kms_key_arn        = var.kms_key_arn
  auth_token         = local.use_auth_token ? data.aws_ssm_parameter.auth_token[0].value : null
  cache              = var.cache
}

# NOTE: CloudWatch alarms removed from this module to avoid circular dependencies
# Cache alarms should be created in environment main.tf INTEGRATIONS section
# This allows monitoring module to be created first, then cache, then alarms
