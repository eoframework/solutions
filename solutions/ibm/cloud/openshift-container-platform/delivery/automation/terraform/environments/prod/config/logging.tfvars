#------------------------------------------------------------------------------
# Logging Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-04 00:34:03
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

logging = {
  efk_enabled = true  # Enable EFK logging stack
  elasticsearch_replicas = 3  # Elasticsearch replica count
  elasticsearch_storage_gb = 500  # Elasticsearch storage per node in GB
  retention_days = 7  # Elasticsearch log retention in days
}
