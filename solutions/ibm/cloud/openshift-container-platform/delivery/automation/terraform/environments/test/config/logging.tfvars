#------------------------------------------------------------------------------
# Logging Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-04 00:34:05
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

logging = {
  efk_enabled = true  # Enable EFK logging stack
  elasticsearch_replicas = 1  # Elasticsearch replica count
  elasticsearch_storage_gb = 100  # Elasticsearch storage per node in GB
  retention_days = 3  # Elasticsearch log retention in days
}
