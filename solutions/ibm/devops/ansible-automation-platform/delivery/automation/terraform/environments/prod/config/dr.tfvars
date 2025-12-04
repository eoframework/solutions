#------------------------------------------------------------------------------
# Dr Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-04 00:34:18
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

dr = {
  db_replication_enabled = true  # Enable database replication
  enabled = true  # Enable DR infrastructure
  rpo_hours = 1  # Recovery Point Objective in hours
  rto_hours = 4  # Recovery Time Objective in hours
  strategy = "ACTIVE_PASSIVE"  # DR strategy
}
