#------------------------------------------------------------------------------
# Disaster Recovery Configuration
# Generated from configuration.csv - Test values
#------------------------------------------------------------------------------

dr = {
  enabled             = false
  strategy            = "BACKUP_ONLY"
  rto_minutes         = 480
  rpo_minutes         = 1440
  failover_mode       = "manual"
  replication_enabled = false
}
