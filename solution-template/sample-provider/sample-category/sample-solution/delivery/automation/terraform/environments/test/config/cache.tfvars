#------------------------------------------------------------------------------
# Cache Configuration - TEST Environment
#------------------------------------------------------------------------------
# ElastiCache configuration for test environment.
# Generated from: delivery/raw/configuration.csv #SHEET: cache
#
# NOTE: Cache module is NOT included in test environment by default.
# These settings are provided for reference if cache is enabled for testing.
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# ElastiCache Deployment
#------------------------------------------------------------------------------

enable_elasticache = false              # Test: disabled by default

# Engine configuration
cache_engine         = "redis"
cache_engine_version = "7.0"

#------------------------------------------------------------------------------
# Instance Configuration (if enabled)
#------------------------------------------------------------------------------

cache_node_type = "cache.t3.micro"      # Test: smallest instance
cache_num_nodes = 1                      # Test: single node

#------------------------------------------------------------------------------
# High Availability
#------------------------------------------------------------------------------

cache_automatic_failover = false         # Test: disabled (single node)

#------------------------------------------------------------------------------
# Encryption
#------------------------------------------------------------------------------

cache_at_rest_encryption  = false        # Test: disabled for simplicity
cache_transit_encryption  = false        # Test: disabled for simplicity

#------------------------------------------------------------------------------
# Backup Configuration
#------------------------------------------------------------------------------

cache_snapshot_retention = 1             # Test: minimal retention
cache_snapshot_window    = "05:00-06:00"
