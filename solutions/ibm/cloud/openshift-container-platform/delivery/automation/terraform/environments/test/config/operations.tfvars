#------------------------------------------------------------------------------
# Operations Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-04 00:34:05
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

backup = {
  enabled = false  # Enable automated backups
  retention_days = 7  # Backup retention period in days
  s3_bucket = "ocp-test-backups"  # S3 bucket for backup storage
  schedule_cron = "0 2 * * *"  # ETCD backup schedule in cron format
}
