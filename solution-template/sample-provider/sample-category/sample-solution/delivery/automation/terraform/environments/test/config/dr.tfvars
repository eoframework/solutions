#------------------------------------------------------------------------------
# DR Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-02
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

dr = {
  enabled                      = false                          # Enable DR infrastructure
  strategy                     = "BACKUP_ONLY"                  # DR strategy
  rto_minutes                  = 480                            # Recovery Time Objective (minutes)
  rpo_minutes                  = 1440                           # Recovery Point Objective (minutes)
  failover_mode                = "manual"                       # Failover mode

  # Cross-region replication (disabled for test)
  replication_enabled          = false                          # Enable cross-region replication

  # DR vault (not used in test)
  vault_enabled                = false                          # Enable DR backup vault
  vault_enable_lock            = false                          # Enable vault lock (WORM)

  # Backup retention
  backup_retention_days        = 30                             # DR backup retention (days)
  backup_local_retention_days  = 7                              # Local backup retention
  enable_weekly_backup         = false                          # Enable DR weekly backup
  weekly_backup_retention_days = 90                             # DR weekly retention

  # DR operations
  test_schedule                = ""                             # DR test schedule (disabled)
  notification_email           = "dr-alerts@example.com"        # DR notification email
}
