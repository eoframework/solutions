#------------------------------------------------------------------------------
# Database Configuration
#------------------------------------------------------------------------------
# RDS database infrastructure settings.
# These values are typically derived from the delivery configuration.csv
# under the "Database" or "Data" sections.
#------------------------------------------------------------------------------

database = {
  #----------------------------------------------------------------------------
  # RDS Engine Configuration
  #----------------------------------------------------------------------------
  engine         = "postgres"
  engine_version = "15.4"
  instance_class = "db.t3.medium"   # Production: appropriately sized

  #----------------------------------------------------------------------------
  # Storage
  #----------------------------------------------------------------------------
  allocated_storage     = 100       # GB initial
  max_allocated_storage = 500       # GB max (autoscaling)
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
  performance_insights = true       # Production: enabled

  #----------------------------------------------------------------------------
  # Protection
  #----------------------------------------------------------------------------
  deletion_protection = true        # Production: enabled
}
