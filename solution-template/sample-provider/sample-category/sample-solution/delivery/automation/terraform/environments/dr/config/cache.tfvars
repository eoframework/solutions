#------------------------------------------------------------------------------
# Cache Configuration - DR Environment
#------------------------------------------------------------------------------
# ElastiCache configuration for disaster recovery.
# Generated from: delivery/raw/configuration.csv #SHEET: cache
#
# DR configuration matches production for failover compatibility.
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# ElastiCache Deployment
#------------------------------------------------------------------------------

enable_elasticache = true               # DR: enabled (matches prod)

# Engine configuration (must match production)
cache_engine         = "redis"
cache_engine_version = "7.0"

#------------------------------------------------------------------------------
# Instance Configuration
#------------------------------------------------------------------------------

cache_node_type = "cache.r6g.large"     # DR: same as production
cache_num_nodes = 2                      # DR: HA configuration

#------------------------------------------------------------------------------
# High Availability
#------------------------------------------------------------------------------

cache_automatic_failover = true          # DR: enabled for HA

#------------------------------------------------------------------------------
# Encryption
#------------------------------------------------------------------------------

cache_at_rest_encryption  = true         # DR: enabled (matches prod)
cache_transit_encryption  = true         # DR: enabled (matches prod)

#------------------------------------------------------------------------------
# Backup Configuration
#------------------------------------------------------------------------------

cache_snapshot_retention = 7             # DR: same as production
cache_snapshot_window    = "05:00-06:00"
