#------------------------------------------------------------------------------
# Database Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 23:05:07
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

database = {
  rds_backup_retention = 1  # RDS backup retention days
  rds_database_name = "tfe_state"  # PostgreSQL database name
  rds_deletion_protection = false  # Enable RDS deletion protection
  rds_instance_class = "db.t3.small"  # RDS instance class for TFE state
  rds_multi_az = false  # Enable RDS Multi-AZ
  rds_storage_gb = 20  # RDS allocated storage in GB
}
