#------------------------------------------------------------------------------
# Database Configuration - DR Environment
#------------------------------------------------------------------------------
# DR database settings. Must match production configuration for replication
# and failover compatibility.
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# RDS Database Configuration (Match Production)
#------------------------------------------------------------------------------

db_engine         = "postgres"        # Must match production
db_engine_version = "15.4"            # Must match production
db_instance_class = "db.t3.medium"    # Same as production for failover

# Storage (same as production)
db_allocated_storage     = 100        # GB initial
db_max_allocated_storage = 500        # GB max (autoscaling)
db_storage_encrypted     = true       # Always enabled for DR

# Database identity (same as production for seamless failover)
db_name     = "appdb"
db_username = "dbadmin"
# db_password = ""                    # Set via environment variable or secrets manager

# High Availability
db_multi_az = true                    # DR: Always enabled for HA

# Backup Configuration (same as production)
db_backup_retention    = 30           # days
db_backup_window       = "03:00-04:00"
db_maintenance_window  = "sun:04:00-sun:05:00"

# Performance & Monitoring
db_performance_insights = true        # DR: Enabled for visibility

# Protection
db_deletion_protection = true         # DR: Always enabled

#------------------------------------------------------------------------------
# ElastiCache (Redis) Configuration
#------------------------------------------------------------------------------

cache_engine_version = "7.0"
cache_node_type      = "cache.t3.medium"
cache_num_nodes      = 2              # DR: HA configuration

# High Availability
cache_automatic_failover = true       # DR: Enabled for HA

# Encryption
cache_at_rest_encryption  = true      # DR: Enabled
cache_transit_encryption  = true      # DR: Enabled

# Backup
cache_snapshot_retention = 7          # days
cache_snapshot_window    = "05:00-06:00"
