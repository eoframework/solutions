#------------------------------------------------------------------------------
# Azure Cosmos DB Module - Outputs
#------------------------------------------------------------------------------

output "id" {
  description = "Cosmos DB account ID"
  value       = azurerm_cosmosdb_account.this.id
}

output "name" {
  description = "Cosmos DB account name"
  value       = azurerm_cosmosdb_account.this.name
}

output "endpoint" {
  description = "Cosmos DB endpoint URL"
  value       = azurerm_cosmosdb_account.this.endpoint
}

output "primary_key" {
  description = "Primary master key"
  value       = azurerm_cosmosdb_account.this.primary_key
  sensitive   = true
}

output "secondary_key" {
  description = "Secondary master key"
  value       = azurerm_cosmosdb_account.this.secondary_key
  sensitive   = true
}

output "primary_readonly_key" {
  description = "Primary readonly key"
  value       = azurerm_cosmosdb_account.this.primary_readonly_key
  sensitive   = true
}

# Note: connection_strings attribute is deprecated in azurerm provider
# Use primary_sql_connection_string or build connection strings from endpoint + key

output "primary_sql_connection_string" {
  description = "Primary SQL connection string"
  value       = "AccountEndpoint=${azurerm_cosmosdb_account.this.endpoint};AccountKey=${azurerm_cosmosdb_account.this.primary_key};"
  sensitive   = true
}

output "sql_database_ids" {
  description = "Map of SQL database names to IDs"
  value       = { for k, v in azurerm_cosmosdb_sql_database.this : k => v.id }
}

output "sql_container_ids" {
  description = "Map of SQL container names to IDs"
  value       = { for k, v in azurerm_cosmosdb_sql_container.this : k => v.id }
}
