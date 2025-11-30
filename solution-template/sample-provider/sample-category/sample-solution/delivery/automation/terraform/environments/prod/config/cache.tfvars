#------------------------------------------------------------------------------
# Cache Configuration - ElastiCache - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-11-30 15:48:18
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

cache = {
  #----------------------------------------------------------------------------
  # Enable/Disable
  #----------------------------------------------------------------------------
  enabled = true

  #----------------------------------------------------------------------------
  # Engine Configuration
  #----------------------------------------------------------------------------
  engine         = "redis"
  engine_version = "7.0"
  port           = 6379

  #----------------------------------------------------------------------------
  # Instance Configuration
  #----------------------------------------------------------------------------
  node_type = "cache.r6g.large"
  num_nodes = 2

  #----------------------------------------------------------------------------
  # High Availability
  #----------------------------------------------------------------------------
  automatic_failover = true

  #----------------------------------------------------------------------------
  # Encryption
  #----------------------------------------------------------------------------
  at_rest_encryption = true
  transit_encryption = true

  # Authentication: Reference to SSM Parameter Store (NOT the actual token)
  # Full parameter path: /${name_prefix}/${auth_token_param_name}
  # Created by: setup/secrets module
  auth_token_param_name = "cache/auth-token"

  #----------------------------------------------------------------------------
  # Backup Configuration
  #----------------------------------------------------------------------------
  snapshot_retention = 7
  snapshot_window    = "05:00-06:00"

  #----------------------------------------------------------------------------
  # Maintenance Configuration
  #----------------------------------------------------------------------------
  maintenance_window         = "sun:06:00-sun:07:00"
  auto_minor_version_upgrade = true

  #----------------------------------------------------------------------------
  # Cluster Mode (Redis only)
  #----------------------------------------------------------------------------
  cluster_mode_enabled  = false
  cluster_mode_replicas = 1
  cluster_mode_shards   = 1
}
