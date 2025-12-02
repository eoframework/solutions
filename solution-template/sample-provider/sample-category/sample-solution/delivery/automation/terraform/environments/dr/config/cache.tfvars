#------------------------------------------------------------------------------
# Cache Configuration - ElastiCache - DR Environment
#------------------------------------------------------------------------------
# Same as production for failover compatibility.
# Cache created fresh in DR - warms from database after failover.
#------------------------------------------------------------------------------

cache = {
  enabled = true

  # Engine Configuration
  engine         = "redis"
  engine_version = "7.0"
  port           = 6379

  # Instance Configuration
  node_type = "cache.r6g.large"
  num_nodes = 2

  # High Availability
  automatic_failover = true

  # Encryption
  at_rest_encryption = true
  transit_encryption = true

  # Backup Configuration
  snapshot_retention = 7
  snapshot_window    = "05:00-06:00"

  # Maintenance Configuration
  maintenance_window         = "sun:06:00-sun:07:00"
  auto_minor_version_upgrade = true

  # Cluster Mode
  cluster_mode_enabled  = false
  cluster_mode_replicas = 1
  cluster_mode_shards   = 1
}
