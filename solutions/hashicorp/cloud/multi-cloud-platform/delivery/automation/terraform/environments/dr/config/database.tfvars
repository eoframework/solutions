#------------------------------------------------------------------------------
# Database Configuration
# Generated from configuration.csv - DR values
#------------------------------------------------------------------------------

database = {
  rds_instance_class      = "db.t3.large"
  rds_storage_gb          = 100
  rds_database_name       = "terraform_cloud"
  rds_multi_az            = true
  rds_backup_retention    = 30
  rds_deletion_protection = true
}
