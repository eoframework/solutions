#------------------------------------------------------------------------------
# Dr Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 23:05:07
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

dr = {
  enabled = true  # Enable DR infrastructure
  failover_mode = "manual"  # Failover mode
  rpo_minutes = 60  # Recovery Point Objective (minutes)
  rto_minutes = 240  # Recovery Time Objective (minutes)
  strategy = "ACTIVE_PASSIVE"  # DR strategy
}
