#------------------------------------------------------------------------------
# Dr Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-04 00:34:02
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

dr = {
  enabled = true  # Enable DR infrastructure
  replication_enabled = true  # Enable cross-region etcd replication
  rpo_hours = 1  # Recovery Point Objective in hours
  rto_hours = 4  # Recovery Time Objective in hours
  strategy = "ACTIVE_PASSIVE"  # DR strategy
}
