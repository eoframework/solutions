# Azure Module Outputs
# Outputs from Azure-specific resources

# Resource Group Outputs
output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_id" {
  description = "ID of the resource group"
  value       = azurerm_resource_group.main.id
}

# Networking Outputs
output "vnet_id" {
  description = "ID of the Virtual Network"
  value       = module.networking.vnet_id
}

output "vnet_name" {
  description = "Name of the Virtual Network"
  value       = module.networking.vnet_name
}

output "subnet_ids" {
  description = "IDs of the subnets"
  value       = module.networking.subnet_ids
}

output "subnet_names" {
  description = "Names of the subnets"
  value       = module.networking.subnet_names
}

# Security Outputs
output "nsg_ids" {
  description = "IDs of the Network Security Groups"
  value       = module.security.nsg_ids
}

output "key_vault_id" {
  description = "ID of the Key Vault"
  value       = module.security.key_vault_id
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = module.security.key_vault_uri
}

# Compute Outputs
output "vm_ids" {
  description = "IDs of the Virtual Machines"
  value       = module.compute.vm_ids
}

output "vm_names" {
  description = "Names of the Virtual Machines"
  value       = module.compute.vm_names
}

output "public_ip_addresses" {
  description = "Public IP addresses of the Virtual Machines"
  value       = module.compute.public_ip_addresses
}

output "private_ip_addresses" {
  description = "Private IP addresses of the Virtual Machines"
  value       = module.compute.private_ip_addresses
}

output "scale_set_id" {
  description = "ID of the Virtual Machine Scale Set"
  value       = module.compute.scale_set_id
}

output "load_balancer_id" {
  description = "ID of the Load Balancer"
  value       = module.compute.load_balancer_id
}

output "sql_database_id" {
  description = "ID of the SQL Database"
  value       = module.compute.sql_database_id
  sensitive   = true
}

output "sql_server_fqdn" {
  description = "FQDN of the SQL Server"
  value       = module.compute.sql_server_fqdn
  sensitive   = true
}

# Resource Summary
output "azure_resource_summary" {
  description = "Summary of Azure resources created"
  value = {
    location              = var.location
    resource_group_name   = azurerm_resource_group.main.name
    vnet_cidr            = var.vnet_cidr
    subnets_created      = length(var.subnet_cidrs)
    vms_created          = length(var.vms)
    scale_set_enabled    = var.enable_scale_set
    load_balancer_enabled = var.enable_load_balancer
    key_vault_enabled    = var.enable_key_vault
  }
}