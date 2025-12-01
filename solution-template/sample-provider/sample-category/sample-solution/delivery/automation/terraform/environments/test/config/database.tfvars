#------------------------------------------------------------------------------
# Database Configuration - RDS - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-11-30 17:01:06
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

database = {
  allocated_storage = 20  # Initial storage (GB)
  allow_major_version_upgrade = false  # Allow Major Version Upgrade
  auto_minor_version_upgrade = true  # Enable auto minor version upgrade
  backup_retention = 7  # Backup Retention
  backup_window = "03:00-04:00"  # Preferred backup window
  copy_tags_to_snapshot = true  # Copy Tags To Snapshot
  deletion_protection = false  # Enable deletion protection
  enabled = true  # Enable this resource
  engine = "postgres"  # Database engine type
  engine_version = "15.4"  # Database engine version
  instance_class = "db.t3.small"  # RDS instance class
  log_exports_mysql = ["error", "slowquery", "general"]  # Log Exports Mysql
  log_exports_postgres = ["postgresql", "upgrade"]  # Log Exports Postgres
  maintenance_window = "sun:04:00-sun:05:00"  # Preferred maintenance window
  max_allocated_storage = 50  # Maximum storage autoscaling (GB)
  multi_az = false  # Enable Multi-AZ deployment
  name = "appdb"  # Solution name for resource naming
  password_secret_name = "db-password"  # Password Secret Name
  performance_insights = false  # Performance Insights
  performance_insights_retention = 7  # Performance Insights retention (days)
  publicly_accessible = false  # Allow public access
  skip_final_snapshot = false  # Skip final snapshot on deletion
  storage_encrypted = true  # Storage Encrypted
  storage_iops = 0  # Provisioned IOPS
  storage_throughput = 0  # Storage throughput (gp3)
  storage_type = "gp3"  # Storage type (gp3/gp2/io1)
  username = "dbadmin"  # Username
}
