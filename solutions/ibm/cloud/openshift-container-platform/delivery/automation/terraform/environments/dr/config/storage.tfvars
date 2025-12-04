#------------------------------------------------------------------------------
# Storage Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-04 00:34:07
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

storage = {
  class_block = "ocs-storagecluster-ceph-rbd"  # Storage class for block storage PVCs
  class_file = "ocs-storagecluster-cephfs"  # Storage class for file storage PVCs
  default_class = "ocs-storagecluster-ceph-rbd"  # Default storage class
  odf_capacity_tb = 20  # Total ODF storage capacity in TB
  odf_enabled = true  # Enable OpenShift Data Foundation
}
