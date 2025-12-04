#------------------------------------------------------------------------------
# Logging Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 22:21:03
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

logging = {
  bigquery_retention_years = 1  # BigQuery export retention years
  enable_audit_logs = true  # Enable Cloud Audit Logs
  enable_data_access_logs = false  # Enable Data Access audit logs
  retention_days = 30  # Cloud Logging retention days
  sink_type = "BigQuery"  # Log export destination type
  volume_gb_month = 100  # Expected monthly log volume (GB)
}
