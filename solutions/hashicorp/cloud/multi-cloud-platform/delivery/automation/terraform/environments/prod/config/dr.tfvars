#------------------------------------------------------------------------------
# Disaster Recovery Configuration
# Generated from configuration.csv - Production values
#------------------------------------------------------------------------------

dr = {
  enabled             = true
  strategy            = "ACTIVE_PASSIVE"
  rto_minutes         = 240
  rpo_minutes         = 60
  failover_mode       = "manual"
  replication_enabled = true
}
