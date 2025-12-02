#------------------------------------------------------------------------------
# Dr Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-02 00:00:41
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

dr = {
  backup_local_retention_days = 7  # Local backup retention
  backup_retention_days = 30  # DR backup retention (days)
  enable_replication_time_control = true  # Enable replication time control
  enable_weekly_backup = false  # Enable DR weekly backup
  enabled = false  # Enable DR infrastructure
  failover_mode = "manual"  # Failover mode
  notification_email = "dr-alerts@example.com"  # DR notification email
  replication_enabled = false  # Enable cross-region replication
  rpo_minutes = 1440  # Recovery Point Objective (minutes)
  rto_minutes = 480  # Recovery Time Objective (minutes)
  storage_replication_class = "STANDARD"  # DR storage class
  strategy = "BACKUP_ONLY"  # DR strategy
  test_schedule = ""  # DR test schedule
  vault_enable_lock = false  # Enable vault lock (WORM)
  vault_enabled = false  # Enable DR backup vault
  vault_kms_deletion_window_days = 30  # DR KMS deletion window
  vault_noncurrent_version_expiration_days = 90  # DR vault noncurrent expiration
  vault_transition_to_ia_days = 30  # DR vault transition to IA
  weekly_backup_retention_days = 90  # DR weekly retention
}
