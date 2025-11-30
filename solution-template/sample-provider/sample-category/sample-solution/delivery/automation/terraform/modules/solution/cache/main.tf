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

#------------------------------------------------------------------------------
# CloudWatch Alarms
#------------------------------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "cache_cpu" {
  count               = var.enable_alarms ? 1 : 0
  alarm_name          = "${local.name_prefix}-cache-cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ElastiCache"
  period              = 300
  statistic           = "Average"
  threshold           = 75
  alarm_description   = "Cache CPU utilization is high"
  dimensions          = { CacheClusterId = module.elasticache.replication_group_id }
  alarm_actions       = var.alarm_sns_topic_arn != "" ? [var.alarm_sns_topic_arn] : []
  tags                = local.common_tags
}

resource "aws_cloudwatch_metric_alarm" "cache_memory" {
  count               = var.enable_alarms ? 1 : 0
  alarm_name          = "${local.name_prefix}-cache-memory-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "DatabaseMemoryUsagePercentage"
  namespace           = "AWS/ElastiCache"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Cache memory usage is high"
  dimensions          = { CacheClusterId = module.elasticache.replication_group_id }
  alarm_actions       = var.alarm_sns_topic_arn != "" ? [var.alarm_sns_topic_arn] : []
  tags                = local.common_tags
}

resource "aws_cloudwatch_metric_alarm" "cache_evictions" {
  count               = var.enable_alarms ? 1 : 0
  alarm_name          = "${local.name_prefix}-cache-evictions-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "Evictions"
  namespace           = "AWS/ElastiCache"
  period              = 300
  statistic           = "Sum"
  threshold           = 1000
  alarm_description   = "Cache eviction rate is high"
  dimensions          = { CacheClusterId = module.elasticache.replication_group_id }
  alarm_actions       = var.alarm_sns_topic_arn != "" ? [var.alarm_sns_topic_arn] : []
  tags                = local.common_tags
}
