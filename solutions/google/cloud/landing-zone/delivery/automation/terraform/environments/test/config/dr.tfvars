#------------------------------------------------------------------------------
# DR Configuration - Test
#------------------------------------------------------------------------------

dr = {
  enabled                  = false
  strategy                 = "BACKUP_ONLY"
  rto_minutes              = 480
  rpo_minutes              = 1440
  failover_mode            = "manual"
  cross_region_replication = false
}
