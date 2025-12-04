#------------------------------------------------------------------------------
# Dr Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-04 00:34:04
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

dr = {
  enabled = false  # Enable DR infrastructure
  replication_enabled = false  # Enable cross-region etcd replication
  rpo_hours = 24  # Recovery Point Objective in hours
  rto_hours = 8  # Recovery Time Objective in hours
  strategy = "BACKUP_ONLY"  # DR strategy
}
