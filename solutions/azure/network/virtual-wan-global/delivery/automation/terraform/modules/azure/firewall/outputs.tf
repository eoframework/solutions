#------------------------------------------------------------------------------
# Azure Firewall Module Outputs
#------------------------------------------------------------------------------

output "id" {
  description = "ID of the Azure Firewall"
  value       = azurerm_firewall.main.id
}

output "name" {
  description = "Name of the Azure Firewall"
  value       = azurerm_firewall.main.name
}

output "policy_id" {
  description = "ID of the Firewall Policy"
  value       = var.create_policy ? azurerm_firewall_policy.main[0].id : var.firewall_policy_id
}

output "private_ip_address" {
  description = "Private IP address of the Firewall"
  value       = azurerm_firewall.main.ip_configuration[0].private_ip_address
}
