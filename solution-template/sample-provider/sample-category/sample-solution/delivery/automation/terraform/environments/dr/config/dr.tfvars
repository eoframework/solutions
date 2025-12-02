#------------------------------------------------------------------------------
# DR Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-02
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

dr = {
  enabled                      = false                          # Enable DR infrastructure
  strategy                     = "ACTIVE_PASSIVE"               # DR strategy
  rto_minutes                  = 240                            # Recovery Time Objective (minutes)
  rpo_minutes                  = 60                             # Recovery Point Objective (minutes)
  failover_mode                = "manual"                       # Failover mode

  # Cross-region replication (DR doesn't replicate further)
  replication_enabled          = false                          # Enable cross-region replication

  # DR vault (receives backups from production)
  vault_enabled                = true                           # Enable DR backup vault
  vault_enable_lock            = false                          # Enable vault lock (WORM)

  # Backup retention
  backup_retention_days        = 30                             # DR backup retention (days)
  backup_local_retention_days  = 7                              # Local backup retention
  enable_weekly_backup         = true                           # Enable DR weekly backup
  weekly_backup_retention_days = 90                             # DR weekly retention

  # DR operations
  test_schedule                = "cron(0 2 ? * SUN *)"          # DR test schedule
  notification_email           = "dr-alerts@example.com"        # DR notification email
}
