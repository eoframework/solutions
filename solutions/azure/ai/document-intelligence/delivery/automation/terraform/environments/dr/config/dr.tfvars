#------------------------------------------------------------------------------
# Dr Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 18:26:50
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

dr = {
  enabled = true  # Enable disaster recovery
  failover_priority = 0  # Failover priority (0=disabled)
  replication_enabled = false  # Enable storage replication
}
