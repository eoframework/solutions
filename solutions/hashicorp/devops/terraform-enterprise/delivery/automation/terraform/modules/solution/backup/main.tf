#------------------------------------------------------------------------------
# Backup Module (Solution-Level)
#------------------------------------------------------------------------------
# Composes aws/backup provider module for Terraform Enterprise backup
# Note: Cross-region DR vault must be created separately at environment level
# with appropriate provider alias
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Primary Backup Module
#------------------------------------------------------------------------------
module "backup" {
  source = "../../aws/backup"

  name_prefix = var.name_prefix
  common_tags = var.common_tags
  kms_key_arn = var.kms_key_arn

  # Daily backup configuration
  daily_schedule       = "cron(0 5 ? * * *)"
  daily_retention_days = var.backup.daily_retention

  # Weekly backup configuration
  weekly_schedule       = "cron(0 5 ? * SUN *)"
  weekly_retention_days = var.backup.weekly_retention

  # Cross-region copy configuration (DR vault ARN passed from environment)
  enable_cross_region_copy = var.backup.enable_cross_region && var.dr_vault_arn != ""
  dr_vault_arn             = var.dr_vault_arn
  dr_retention_days        = var.backup.daily_retention

  # Resources to backup
  resource_arns = [var.rds_arn]
}
