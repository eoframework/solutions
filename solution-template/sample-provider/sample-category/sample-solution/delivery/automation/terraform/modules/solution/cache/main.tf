# Solution Cache Module
# Deploys: ElastiCache Redis cluster with subnet group and encryption
#
# This module is optional - only include in environments that need caching.
#
# Uses generic AWS ElastiCache module for reusable components.

terraform {
  required_version = ">= 1.6.0"
}

locals {
  name_prefix = var.name_prefix
  common_tags = var.common_tags
}

#------------------------------------------------------------------------------
# ElastiCache Redis (using generic ElastiCache module)
#------------------------------------------------------------------------------

module "elasticache" {
  source = "../../aws/elasticache"

  name_prefix                = local.name_prefix
  tags                       = local.common_tags
  subnet_group_name          = var.elasticache_subnet_group_name
  security_group_ids         = var.security_group_ids
  engine_version             = var.cache_engine_version
  node_type                  = var.cache_node_type
  num_cache_clusters         = var.cache_num_nodes
  automatic_failover_enabled = var.cache_automatic_failover
  at_rest_encryption_enabled = var.cache_at_rest_encryption
  transit_encryption_enabled = var.cache_transit_encryption
  kms_key_arn                = var.cache_at_rest_encryption ? var.kms_key_arn : null
  maintenance_window         = var.cache_maintenance_window
  snapshot_retention_limit   = var.cache_snapshot_retention
  snapshot_window            = var.cache_snapshot_window
  notification_topic_arn     = var.notification_topic_arn
  parameters                 = var.cache_parameters
}

#------------------------------------------------------------------------------
# CloudWatch Alarms
#------------------------------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "cache_cpu" {
  count = var.enable_alarms ? 1 : 0

  alarm_name          = "${local.name_prefix}-cache-cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ElastiCache"
  period              = 300
  statistic           = "Average"
  threshold           = 75
  alarm_description   = "Cache CPU utilization is high"

  dimensions = {
    CacheClusterId = module.elasticache.replication_group_id
  }

  alarm_actions = var.alarm_sns_topic_arn != "" ? [var.alarm_sns_topic_arn] : []

  tags = local.common_tags
}

resource "aws_cloudwatch_metric_alarm" "cache_memory" {
  count = var.enable_alarms ? 1 : 0

  alarm_name          = "${local.name_prefix}-cache-memory-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "DatabaseMemoryUsagePercentage"
  namespace           = "AWS/ElastiCache"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Cache memory usage is high"

  dimensions = {
    CacheClusterId = module.elasticache.replication_group_id
  }

  alarm_actions = var.alarm_sns_topic_arn != "" ? [var.alarm_sns_topic_arn] : []

  tags = local.common_tags
}

resource "aws_cloudwatch_metric_alarm" "cache_evictions" {
  count = var.enable_alarms ? 1 : 0

  alarm_name          = "${local.name_prefix}-cache-evictions-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "Evictions"
  namespace           = "AWS/ElastiCache"
  period              = 300
  statistic           = "Sum"
  threshold           = 1000
  alarm_description   = "Cache eviction rate is high"

  dimensions = {
    CacheClusterId = module.elasticache.replication_group_id
  }

  alarm_actions = var.alarm_sns_topic_arn != "" ? [var.alarm_sns_topic_arn] : []

  tags = local.common_tags
}
