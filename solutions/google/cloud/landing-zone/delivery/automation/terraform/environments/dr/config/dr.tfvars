#------------------------------------------------------------------------------
# DR Configuration - DR
#------------------------------------------------------------------------------

dr = {
  enabled                  = true
  strategy                 = "ACTIVE_PASSIVE"
  rto_minutes              = 240
  rpo_minutes              = 60
  failover_mode            = "manual"
  cross_region_replication = true
}
