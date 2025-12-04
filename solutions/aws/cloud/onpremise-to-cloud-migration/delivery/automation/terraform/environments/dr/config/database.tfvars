#------------------------------------------------------------------------------
# Database Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 17:52:48
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

database = {
  allocated_storage = 100  # Storage in GB
  backup_retention_days = 7  # Backup retention in days
  backup_window = "03:00-04:00"  # Preferred backup window (UTC)
  database_name = "appdb"  # Database name
  enable_deletion_protection = true  # Enable DB deletion protection
  enable_performance_insights = true  # Enable Performance Insights
  enable_read_replica = false  # Create read replica
  engine = "mysql"  # Database engine type
  engine_version = "8.0.35"  # RDS engine version
  instance_class = "db.m5.large"  # RDS instance class
  maintenance_window = "sun:04:00-sun:05:00"  # Preferred maintenance window (UTC)
  master_password = "CHANGE_ME_DR"  # Master database password
  master_username = "admin"  # Master database username
  max_allocated_storage = 500  # Max storage for auto-scaling
  multi_az = true  # Enable Multi-AZ deployment
  skip_final_snapshot = false  # Skip final snapshot on delete
}
