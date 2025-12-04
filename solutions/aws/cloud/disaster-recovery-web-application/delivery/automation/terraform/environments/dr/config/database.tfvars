#------------------------------------------------------------------------------
# Database Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 17:57:13
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

database = {
  backup_retention_days = 7  # Backup retention in days
  backup_window = "03:00-04:00"  # Preferred backup window (UTC)
  database_name = "webapp"  # Database name
  enable_deletion_protection = true  # Enable DB deletion protection
  enable_performance_insights = true  # Enable Performance Insights
  engine_version = "8.0.mysql_aurora.3.04.0"  # Aurora MySQL engine version
  instance_class = "db.r6g.large"  # Aurora instance class
  instance_count = 2  # Number of Aurora instances
  # Is this the primary region for Aurora Global
  is_primary_region = false
  maintenance_window = "sun:04:00-sun:05:00"  # Preferred maintenance window (UTC)
  master_password = "CHANGE_ME_DR"  # Master database password
  master_username = "admin"  # Master database username
  monitoring_interval = 60  # Enhanced monitoring interval (seconds)
  skip_final_snapshot = false  # Skip final snapshot on delete
}
