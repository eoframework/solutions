#------------------------------------------------------------------------------
# Database Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 18:26:48
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

database = {
  cosmos_backup_interval_hours = 4  # Backup interval in hours (Periodic)
  cosmos_backup_retention_hours = 720  # Backup retention in hours
  cosmos_backup_type = "Continuous"  # Backup type for Cosmos DB
  cosmos_consistency_level = "Session"  # Consistency level for reads
  cosmos_database_name = "documentprocessing"  # Database name
  cosmos_enable_free_tier = false  # Enable free tier pricing
  cosmos_max_throughput = 4000  # Maximum RU/s for autoscale
  cosmos_metadata_container = "document-metadata"  # Container for document metadata
  cosmos_offer_type = "Standard"  # Cosmos DB offer type
  cosmos_results_container = "extraction-results"  # Container for extraction results
}
