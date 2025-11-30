# Generic AWS ElastiCache Module
# Creates ElastiCache Redis replication group

#------------------------------------------------------------------------------
# Parameter Group
#------------------------------------------------------------------------------

resource "aws_elasticache_parameter_group" "this" {
  name   = "${var.name_prefix}-cache-params"
  family = "redis${split(".", var.cache.engine_version)[0]}"

  tags = merge(var.tags, { Name = "${var.name_prefix}-cache-params" })
}

#------------------------------------------------------------------------------
# Replication Group
#------------------------------------------------------------------------------

resource "aws_elasticache_replication_group" "this" {
  replication_group_id = "${var.name_prefix}-cache"
  description          = "Redis cache for ${var.name_prefix}"

  engine               = var.cache.engine
  engine_version       = var.cache.engine_version
  node_type            = var.cache.node_type
  parameter_group_name = aws_elasticache_parameter_group.this.name
  port                 = var.cache.port

  num_cache_clusters         = var.cache.cluster_mode_enabled ? null : var.cache.num_nodes
  automatic_failover_enabled = var.cache.automatic_failover && var.cache.num_nodes > 1

  # Cluster Mode (Redis only)
  num_node_groups         = var.cache.cluster_mode_enabled ? var.cache.cluster_mode_shards : null
  replicas_per_node_group = var.cache.cluster_mode_enabled ? var.cache.cluster_mode_replicas : null

  subnet_group_name  = var.subnet_group_name
  security_group_ids = var.security_group_ids

  at_rest_encryption_enabled = var.cache.at_rest_encryption
  transit_encryption_enabled = var.cache.transit_encryption
  kms_key_id                 = var.cache.at_rest_encryption ? var.kms_key_arn : null
  auth_token                 = var.cache.transit_encryption ? var.auth_token : null

  maintenance_window         = var.cache.maintenance_window
  snapshot_retention_limit   = var.cache.snapshot_retention
  snapshot_window            = var.cache.snapshot_window
  auto_minor_version_upgrade = var.cache.auto_minor_version_upgrade

  tags = merge(var.tags, { Name = "${var.name_prefix}-cache" })
}
