#------------------------------------------------------------------------------
# Database Configuration
#------------------------------------------------------------------------------
# Database infrastructure settings including RDS and ElastiCache.
# These values are typically derived from the delivery configuration.csv
# under the "Database" or "Data" sections.
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# RDS Database Configuration
#------------------------------------------------------------------------------

db_engine         = "postgres"
db_engine_version = "15.4"
db_instance_class = "db.t3.medium"   # Production: appropriately sized

# Storage
db_allocated_storage     = 100       # GB initial
db_max_allocated_storage = 500       # GB max (autoscaling)
db_storage_encrypted     = true      # Production: always enabled

# Database identity
db_name     = "appdb"
db_username = "dbadmin"
# db_password = ""                   # Set via environment variable or secrets manager

# High Availability
db_multi_az = true                   # Production: always enabled

# Backup Configuration
db_backup_retention    = 30          # days
db_backup_window       = "03:00-04:00"
db_maintenance_window  = "sun:04:00-sun:05:00"

# Performance & Monitoring
db_performance_insights = true       # Production: enabled

# Protection
db_deletion_protection = true        # Production: enabled

#------------------------------------------------------------------------------
# ElastiCache (Redis) Configuration
#------------------------------------------------------------------------------

cache_engine_version = "7.0"
cache_node_type      = "cache.t3.medium"
cache_num_nodes      = 2             # Production: minimum 2 for HA

# High Availability
cache_automatic_failover = true      # Production: enabled

# Encryption
cache_at_rest_encryption  = true     # Production: enabled
cache_transit_encryption  = true     # Production: enabled

# Backup
cache_snapshot_retention = 7         # days
cache_snapshot_window    = "05:00-06:00"
