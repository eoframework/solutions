#------------------------------------------------------------------------------
# Registry Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-04 00:34:05
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

registry = {
  internal_registry_replicas = 1  # Internal registry replica count
  quay_enabled = false  # Enable Quay container registry
  quay_hostname = "quay.apps.ocp-test.example.com"  # Quay container registry hostname
  quay_storage_gb = 100  # Quay image storage capacity in GB
}
