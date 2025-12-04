#------------------------------------------------------------------------------
# Registry Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-04 00:34:07
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

registry = {
  internal_registry_replicas = 2  # Internal registry replica count
  quay_enabled = true  # Enable Quay container registry
  quay_hostname = "quay.apps.ocp-dr.example.com"  # Quay container registry hostname
  quay_storage_gb = 1000  # Quay image storage capacity in GB
}
