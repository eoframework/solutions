#------------------------------------------------------------------------------
# Logging Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 22:21:03
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

logging = {
  bigquery_retention_years = 7  # BigQuery export retention years
  enable_audit_logs = true  # Enable Cloud Audit Logs
  enable_data_access_logs = true  # Enable Data Access audit logs
  retention_days = 365  # Cloud Logging retention days
  sink_type = "BigQuery"  # Log export destination type
  volume_gb_month = 250  # Expected monthly log volume (GB)
}
