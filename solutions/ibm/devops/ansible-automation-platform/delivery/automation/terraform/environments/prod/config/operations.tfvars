#------------------------------------------------------------------------------
# Operations Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-04 00:34:19
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

backup = {
  enabled = true  # Enable automated backups
  retention_days = 30  # Backup retention in days
  s3_bucket = "aap-prod-backups"  # S3 bucket for backup storage
  schedule_cron = "0 2 * * *"  # Backup schedule in cron format
}
