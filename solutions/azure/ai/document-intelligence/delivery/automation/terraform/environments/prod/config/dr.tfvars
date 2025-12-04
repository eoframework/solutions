#------------------------------------------------------------------------------
# Dr Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 18:26:48
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

dr = {
  enabled = true  # Enable disaster recovery
  failover_priority = 1  # Failover priority (0=disabled)
  replication_enabled = true  # Enable storage replication
}
