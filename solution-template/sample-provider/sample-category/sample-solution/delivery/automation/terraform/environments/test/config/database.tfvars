#------------------------------------------------------------------------------
# Database Configuration - TEST Environment
#------------------------------------------------------------------------------
# Minimal RDS configuration for testing.
# Note: Cache module is NOT included in test environment.
#------------------------------------------------------------------------------

db_engine         = "postgres"
db_engine_version = "15.4"
db_instance_class = "db.t3.micro"     # Test: smallest instance

db_allocated_storage     = 20         # Test: minimum storage
db_max_allocated_storage = 50
db_storage_encrypted     = false      # Test: disabled for simplicity

db_name     = "testdb"
db_username = "dbadmin"
# db_password = ""                    # Set via environment variable

db_multi_az = false                   # Test: single-AZ (no HA needed)

db_backup_retention    = 1            # Test: minimal retention
db_backup_window       = "03:00-04:00"
db_maintenance_window  = "sun:04:00-sun:05:00"

db_performance_insights = false       # Test: disabled
db_deletion_protection = false        # Test: disabled for easy teardown
