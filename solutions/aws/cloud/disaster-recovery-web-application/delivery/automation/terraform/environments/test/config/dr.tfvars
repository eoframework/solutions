#------------------------------------------------------------------------------
# Dr Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 17:57:13
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

dr = {
  backup_retention_days = 7  # Local backup retention
  dr_backup_retention_days = 0  # DR backup retention
  enable_continuous_backup = false  # Enable PITR continuous backup
  enable_weekly_backup = false  # Enable weekly backups
  enabled = false  # Enable DR features
  replication_enabled = false  # Enable replication from primary
  rpo_target_minutes = 0  # Recovery Point Objective (minutes)
  rto_target_minutes = 0  # Recovery Time Objective (minutes)
  vault_enabled = false  # Enable DR vault
  vault_kms_deletion_window_days = 7  # DR vault KMS deletion window
  vault_noncurrent_version_expiration_days = 7  # DR bucket version expiration
  vault_transition_to_ia_days = 30  # DR bucket IA transition days
  weekly_backup_retention_days = 0  # Weekly backup retention
}
