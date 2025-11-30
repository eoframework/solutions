#------------------------------------------------------------------------------
# Database Configuration - PRODUCTION Environment
#------------------------------------------------------------------------------
# RDS database infrastructure settings.
# These values are typically derived from the delivery configuration.csv
# under the "Database" or "Data" sections.
#------------------------------------------------------------------------------

database = {
  #----------------------------------------------------------------------------
  # Enable/Disable Database
  #----------------------------------------------------------------------------
  enabled = true

  #----------------------------------------------------------------------------
  # RDS Engine Configuration
  #----------------------------------------------------------------------------
  engine         = "postgres"
  engine_version = "15.4"
  instance_class = "db.t3.medium"   # Production: appropriately sized

  #----------------------------------------------------------------------------
  # Storage Configuration
  #----------------------------------------------------------------------------
  allocated_storage     = 100       # GB initial
  max_allocated_storage = 500       # GB max (autoscaling)
  storage_type          = "gp3"     # gp2, gp3, io1, io2
  storage_iops          = 3000      # Only for io1/io2/gp3
  storage_throughput    = 125       # MB/s, only for gp3
  storage_encrypted     = true      # Production: always enabled

  #----------------------------------------------------------------------------
  # Database Identity
  #----------------------------------------------------------------------------
  name     = "appdb"
  username = "dbadmin"
  # password = ""                   # Set via environment variable or secrets manager

  #----------------------------------------------------------------------------
  # High Availability
  #----------------------------------------------------------------------------
  multi_az = true                   # Production: always enabled

  #----------------------------------------------------------------------------
  # Backup Configuration
  #----------------------------------------------------------------------------
  backup_retention   = 30           # days
  backup_window      = "03:00-04:00"
  maintenance_window = "sun:04:00-sun:05:00"

  #----------------------------------------------------------------------------
  # Performance & Monitoring
  #----------------------------------------------------------------------------
  performance_insights           = true       # Production: enabled
  performance_insights_retention = 7          # days (7 free, 731 paid)

  #----------------------------------------------------------------------------
  # Logging Configuration
  #----------------------------------------------------------------------------
  # PostgreSQL logs to export to CloudWatch
  log_exports_postgres = ["postgresql", "upgrade"]

  # MySQL logs to export to CloudWatch
  log_exports_mysql = ["error", "slowquery", "general"]

  #----------------------------------------------------------------------------
  # Version Management
  #----------------------------------------------------------------------------
  auto_minor_version_upgrade = true   # Auto-apply minor version updates
  allow_major_version_upgrade = false # Require manual major version upgrades

  #----------------------------------------------------------------------------
  # Protection
  #----------------------------------------------------------------------------
  deletion_protection   = true        # Production: enabled
  skip_final_snapshot   = false       # Production: always create final snapshot
  copy_tags_to_snapshot = true        # Copy tags to snapshots

  #----------------------------------------------------------------------------
  # Network
  #----------------------------------------------------------------------------
  publicly_accessible = false         # Production: never public
}
