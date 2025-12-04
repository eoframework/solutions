#------------------------------------------------------------------------------
# Dr Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 17:57:13
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

dr = {
  backup_retention_days = 30  # Local backup retention
  dr_backup_retention_days = 90  # DR backup retention
  enable_continuous_backup = false  # Enable PITR continuous backup
  enable_weekly_backup = true  # Enable weekly backups
  enabled = true  # Enable DR features
  replication_enabled = true  # Enable replication from primary
  rpo_target_minutes = 60  # Recovery Point Objective (minutes)
  rto_target_minutes = 240  # Recovery Time Objective (minutes)
  vault_enabled = true  # Enable DR vault
  vault_kms_deletion_window_days = 30  # DR vault KMS deletion window
  vault_noncurrent_version_expiration_days = 30  # DR bucket version expiration
  vault_transition_to_ia_days = 30  # DR bucket IA transition days
  weekly_backup_retention_days = 90  # Weekly backup retention
}
