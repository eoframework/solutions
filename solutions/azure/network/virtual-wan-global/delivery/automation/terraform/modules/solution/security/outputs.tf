#------------------------------------------------------------------------------
# Virtual WAN Security Module Outputs
#------------------------------------------------------------------------------

output "primary_firewall_id" {
  description = "ID of the primary Azure Firewall"
  value       = var.enable_firewall ? module.primary_firewall[0].id : null
}

output "primary_firewall_name" {
  description = "Name of the primary Azure Firewall"
  value       = var.enable_firewall ? module.primary_firewall[0].name : null
}

output "primary_firewall_policy_id" {
  description = "ID of the primary Firewall Policy"
  value       = var.enable_firewall ? module.primary_firewall[0].policy_id : null
}

output "primary_firewall_private_ip" {
  description = "Private IP of the primary Azure Firewall"
  value       = var.enable_firewall ? module.primary_firewall[0].private_ip_address : null
}

output "secondary_firewall_id" {
  description = "ID of the secondary Azure Firewall"
  value       = var.enable_firewall && var.enable_secondary_hub ? module.secondary_firewall[0].id : null
}

output "secondary_firewall_name" {
  description = "Name of the secondary Azure Firewall"
  value       = var.enable_firewall && var.enable_secondary_hub ? module.secondary_firewall[0].name : null
}

output "secondary_firewall_policy_id" {
  description = "ID of the secondary Firewall Policy"
  value       = var.enable_firewall && var.enable_secondary_hub ? module.secondary_firewall[0].policy_id : null
}

output "secondary_firewall_private_ip" {
  description = "Private IP of the secondary Azure Firewall"
  value       = var.enable_firewall && var.enable_secondary_hub ? module.secondary_firewall[0].private_ip_address : null
}
