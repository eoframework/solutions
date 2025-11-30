#------------------------------------------------------------------------------
# Cache Configuration - PRODUCTION Environment
#------------------------------------------------------------------------------
# ElastiCache Redis/Memcached configuration for production workloads.
# Generated from: delivery/raw/configuration.csv #SHEET: cache
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# ElastiCache Deployment
#------------------------------------------------------------------------------

enable_elasticache = true

# Engine configuration
cache_engine         = "redis"
cache_engine_version = "7.0"

#------------------------------------------------------------------------------
# Instance Configuration
#------------------------------------------------------------------------------

cache_node_type = "cache.r6g.large"    # Production: memory-optimized
cache_num_nodes = 2                     # Production: HA with 2 nodes

#------------------------------------------------------------------------------
# High Availability
#------------------------------------------------------------------------------

cache_automatic_failover = true         # Production: enabled for HA

#------------------------------------------------------------------------------
# Encryption
#------------------------------------------------------------------------------

cache_at_rest_encryption  = true        # Production: enabled
cache_transit_encryption  = true        # Production: enabled

#------------------------------------------------------------------------------
# Backup Configuration
#------------------------------------------------------------------------------

cache_snapshot_retention = 7            # 7 days retention
cache_snapshot_window    = "05:00-06:00" # 5-6 AM UTC
