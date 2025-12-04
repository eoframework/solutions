#------------------------------------------------------------------------------
# Dr Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 18:26:49
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

dr = {
  enabled = false  # Enable disaster recovery
  failover_priority = 0  # Failover priority (0=disabled)
  replication_enabled = false  # Enable storage replication
}
