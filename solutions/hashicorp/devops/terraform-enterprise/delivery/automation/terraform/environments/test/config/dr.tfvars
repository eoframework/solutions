#------------------------------------------------------------------------------
# Dr Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 23:05:07
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

dr = {
  enabled = false  # Enable DR infrastructure
  failover_mode = "manual"  # Failover mode
  rpo_minutes = 1440  # Recovery Point Objective (minutes)
  rto_minutes = 480  # Recovery Time Objective (minutes)
  strategy = "BACKUP_ONLY"  # DR strategy
}
