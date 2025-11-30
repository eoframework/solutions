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
}
