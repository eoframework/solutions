# Generic AWS ElastiCache Module
# Creates ElastiCache Redis replication group

terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

#------------------------------------------------------------------------------
# Parameter Group
#------------------------------------------------------------------------------

resource "aws_elasticache_parameter_group" "this" {
  name   = "${var.name_prefix}-cache-params"
  family = "redis${split(".", var.engine_version)[0]}"

  dynamic "parameter" {
    for_each = var.parameters
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-cache-params"
  })
}

#------------------------------------------------------------------------------
# Replication Group
#------------------------------------------------------------------------------

resource "aws_elasticache_replication_group" "this" {
  replication_group_id = "${var.name_prefix}-cache"
  description          = "Redis cache for ${var.name_prefix}"

  engine               = "redis"
  engine_version       = var.engine_version
  node_type            = var.node_type
  parameter_group_name = aws_elasticache_parameter_group.this.name
  port                 = var.port

  num_cache_clusters         = var.num_cache_clusters
  automatic_failover_enabled = var.automatic_failover_enabled && var.num_cache_clusters > 1

  subnet_group_name  = var.subnet_group_name
  security_group_ids = var.security_group_ids

  at_rest_encryption_enabled = var.at_rest_encryption_enabled
  transit_encryption_enabled = var.transit_encryption_enabled
  kms_key_id                 = var.at_rest_encryption_enabled ? var.kms_key_arn : null

  maintenance_window       = var.maintenance_window
  snapshot_retention_limit = var.snapshot_retention_limit
  snapshot_window          = var.snapshot_window
  auto_minor_version_upgrade = var.auto_minor_version_upgrade

  notification_topic_arn = var.notification_topic_arn

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-cache"
  })
}
