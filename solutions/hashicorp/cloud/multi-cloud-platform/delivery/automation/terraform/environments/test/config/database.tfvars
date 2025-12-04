#------------------------------------------------------------------------------
# Database Configuration
# Generated from configuration.csv - Test values
#------------------------------------------------------------------------------

database = {
  rds_instance_class      = "db.t3.medium"
  rds_storage_gb          = 50
  rds_database_name       = "terraform_cloud"
  rds_multi_az            = false
  rds_backup_retention    = 7
  rds_deletion_protection = false
}
