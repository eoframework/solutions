#------------------------------------------------------------------------------
# Storage Module Outputs
#------------------------------------------------------------------------------

output "storage_account_id" {
  description = "ID of the FSLogix storage account"
  value       = module.storage_account.id
}

output "storage_account_name" {
  description = "Name of the FSLogix storage account"
  value       = module.storage_account.name
}

output "fslogix_share_name" {
  description = "Name of the FSLogix file share"
  value       = "fslogix-profiles"
}

output "fslogix_share_url" {
  description = "URL of the FSLogix file share"
  value       = "\\\\${module.storage_account.name}.file.core.windows.net\\fslogix-profiles"
}

output "storage_account_primary_endpoint" {
  description = "Primary file endpoint of the storage account"
  value       = module.storage_account.primary_file_endpoint
}
