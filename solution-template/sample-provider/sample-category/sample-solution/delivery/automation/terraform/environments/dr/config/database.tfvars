#------------------------------------------------------------------------------
# Database Configuration - RDS - DR Environment
#------------------------------------------------------------------------------
# Same as production for failover compatibility.
# RDS restored from AWS Backup snapshot when failover triggered.
#------------------------------------------------------------------------------

database = {
  enabled = true

  # Engine Configuration (MUST MATCH PRODUCTION)
  engine         = "postgres"
  engine_version = "15.4"
  instance_class = "db.t3.medium"

  # Storage Configuration
  allocated_storage     = 100
  max_allocated_storage = 500
  storage_type          = "gp3"
  storage_iops          = 3000
  storage_throughput    = 125
  storage_encrypted     = true

  # Database Identity
  name     = "appdb"
  username = "dbadmin"

  # High Availability
  multi_az = true

  # Backup Configuration
  backup_retention   = 30
  backup_window      = "03:00-04:00"
  maintenance_window = "sun:04:00-sun:05:00"

  # Performance & Monitoring
  performance_insights           = true
  performance_insights_retention = 7
  log_exports_postgres           = ["postgresql", "upgrade"]
  log_exports_mysql              = ["error", "slowquery", "general"]

  # Version Management
  auto_minor_version_upgrade  = true
  allow_major_version_upgrade = false

  # Protection
  deletion_protection   = true
  skip_final_snapshot   = false
  copy_tags_to_snapshot = true

  # Network
  publicly_accessible = false
}
