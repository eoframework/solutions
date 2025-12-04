#------------------------------------------------------------------------------
# Migration Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 17:52:48
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

migration = {
  dms_instance_class = "dms.t3.medium"  # DMS replication instance class
  dms_storage_gb = 50  # DMS replication storage GB
  mgn_replication_server_type = "t3.small"  # MGN replication server type
  mgn_staging_disk_type = "gp3"  # MGN staging disk type
}
