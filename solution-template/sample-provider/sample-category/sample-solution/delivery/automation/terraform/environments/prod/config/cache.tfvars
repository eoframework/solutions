#------------------------------------------------------------------------------
# Cache Configuration - ElastiCache - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-11-30 15:48:18
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

cache = {
  at_rest_encryption = true  # At Rest Encryption
  auto_minor_version_upgrade = true  # Enable auto minor version upgrade
  automatic_failover = true  # Automatic Failover
  cluster_mode_enabled = false  # Cluster Mode Enabled
  cluster_mode_replicas = 1  # Cluster Mode Replicas
  cluster_mode_shards = 1  # Cluster Mode Shards
  enabled = true  # Enable this resource
  engine = "redis"  # Database engine type
  engine_version = "7.0"  # Database engine version
  maintenance_window = "sun:06:00-sun:07:00"  # Preferred maintenance window
  node_type = "cache.r6g.large"  # ElastiCache node type
  num_nodes = 2  # Num Nodes
  port = 6379  # Cache port number
  snapshot_retention = 7  # Snapshot Retention
  snapshot_window = "05:00-06:00"  # Preferred snapshot window
  transit_encryption = true  # Transit Encryption
}
