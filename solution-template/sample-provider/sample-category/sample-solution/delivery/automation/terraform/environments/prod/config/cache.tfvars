#------------------------------------------------------------------------------
# Cache Configuration - PRODUCTION Environment
#------------------------------------------------------------------------------
# ElastiCache Redis/Memcached configuration for production workloads.
# Generated from: delivery/raw/configuration.csv #SHEET: cache
#------------------------------------------------------------------------------

cache = {
  #----------------------------------------------------------------------------
  # ElastiCache Deployment
  #----------------------------------------------------------------------------
  enabled = true

  # Engine configuration
  engine         = "redis"
  engine_version = "7.0"
  port           = 6379              # Redis default, 11211 for Memcached

  #----------------------------------------------------------------------------
  # Instance Configuration
  #----------------------------------------------------------------------------
  node_type = "cache.r6g.large"       # Production: memory-optimized
  num_nodes = 2                        # Production: HA with 2 nodes

  #----------------------------------------------------------------------------
  # High Availability
  #----------------------------------------------------------------------------
  automatic_failover = true            # Production: enabled for HA

  #----------------------------------------------------------------------------
  # Encryption
  #----------------------------------------------------------------------------
  at_rest_encryption = true            # Production: enabled
  transit_encryption = true            # Production: enabled

  #----------------------------------------------------------------------------
  # Backup Configuration
  #----------------------------------------------------------------------------
  snapshot_retention = 7               # 7 days retention
  snapshot_window    = "05:00-06:00"   # 5-6 AM UTC

  #----------------------------------------------------------------------------
  # Maintenance Configuration
  #----------------------------------------------------------------------------
  maintenance_window         = "sun:06:00-sun:07:00"  # After backup window
  auto_minor_version_upgrade = true                    # Auto-apply patches

  #----------------------------------------------------------------------------
  # Parameter Group Settings
  #----------------------------------------------------------------------------
  # parameter_group_family = "redis7"  # Auto-derived from engine_version

  #----------------------------------------------------------------------------
  # Cluster Mode (Redis only)
  #----------------------------------------------------------------------------
  cluster_mode_enabled    = false      # Enable for horizontal scaling
  cluster_mode_replicas   = 1          # Replicas per shard (if cluster mode)
  cluster_mode_shards     = 1          # Number of shards (if cluster mode)
}
