#------------------------------------------------------------------------------
# Operations Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-04 00:34:07
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

backup = {
  enabled = true  # Enable automated backups
  retention_days = 30  # Backup retention period in days
  s3_bucket = "ocp-dr-backups"  # S3 bucket for backup storage
  schedule_cron = "0 2 * * *"  # ETCD backup schedule in cron format
}
