#------------------------------------------------------------------------------
# Cache Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-01 22:34:04
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

cache = {
  at_rest_encryption = true  # Enable at-rest encryption
  automatic_failover = false  # Enable automatic failover
  enabled = true  # Enable ElastiCache Redis
  engine = "redis"  # Cache engine
  engine_version = "7.0"  # Cache engine version
  maintenance_window = "sun:06:00-sun:07:00"  # Maintenance window
  node_type = "cache.t3.micro"  # Cache node type
  num_nodes = 1  # Number of cache nodes
  port = 6379  # Cache port
  snapshot_retention = 1  # Snapshot retention (days)
  snapshot_window = "05:00-06:00"  # Snapshot window
  transit_encryption = true  # Enable transit encryption
}
