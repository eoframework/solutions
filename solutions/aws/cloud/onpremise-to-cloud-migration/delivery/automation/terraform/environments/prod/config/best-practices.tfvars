#------------------------------------------------------------------------------
# Best Practices Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 17:52:47
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

backup = {
  daily_retention = 30  # Daily backup retention days
  enable_vault_lock = false  # Enable backup vault lock
  enabled = true  # Enable AWS Backup
  monthly_retention = 365  # Monthly backup retention days
  weekly_retention = 90  # Weekly backup retention days
}

budget = {
  alert_thresholds = [50, 80, 100]  # Alert thresholds %
  enabled = true  # Enable AWS Budget
  monthly_amount = 15000  # Monthly budget USD
  notification_email = "finance@company.com"  # Budget alert email
}

config_rules = {
  ebs_encryption_check = true  # EBS encryption check
  enabled = true  # Enable AWS Config Rules
  rds_encryption_check = true  # RDS encryption check
  s3_encryption_check = true  # S3 encryption check
}

guardduty = {
  enabled = true  # Enable GuardDuty
}
