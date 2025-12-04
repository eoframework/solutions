#------------------------------------------------------------------------------
# Storage Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 18:26:50
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

storage = {
  account_tier = "Standard"  # Storage account tier
  archive_container = "archive-documents"  # Container for archived documents
  failed_container = "failed-documents"  # Container for failed documents
  input_container = "input-documents"  # Container for incoming documents
  processed_container = "processed-documents"  # Container for processed documents
  replication_type = "GRS"  # Storage replication type
  retention_cool_days = 60  # Days in cool tier before archive
  retention_hot_days = 30  # Days in hot tier before transition
  retention_total_days = 2555  # Total retention in days (7 years)
}
