#------------------------------------------------------------------------------
# Migration Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 17:52:47
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

migration = {
  dms_instance_class = "dms.r5.large"  # DMS replication instance class
  dms_storage_gb = 100  # DMS replication storage GB
  mgn_replication_server_type = "t3.small"  # MGN replication server type
  mgn_staging_disk_type = "gp3"  # MGN staging disk type
}
