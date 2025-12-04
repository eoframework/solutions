#------------------------------------------------------------------------------
# Operations Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-04 00:34:19
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

backup = {
  enabled = false  # Enable automated backups
  retention_days = 7  # Backup retention in days
  s3_bucket = "aap-test-backups"  # S3 bucket for backup storage
  schedule_cron = "0 2 * * *"  # Backup schedule in cron format
}
