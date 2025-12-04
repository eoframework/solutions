#------------------------------------------------------------------------------
# Dr Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-04 00:34:19
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

dr = {
  db_replication_enabled = false  # Enable database replication
  enabled = false  # Enable DR infrastructure
  rpo_hours = 24  # Recovery Point Objective in hours
  rto_hours = 8  # Recovery Time Objective in hours
  strategy = "BACKUP_ONLY"  # DR strategy
}
