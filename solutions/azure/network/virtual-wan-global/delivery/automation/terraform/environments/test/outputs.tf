#------------------------------------------------------------------------------
# Azure Virtual WAN Global - Production Environment Outputs
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Core Infrastructure
#------------------------------------------------------------------------------
output "resource_group_name" {
  description = "Name of the resource group"
  value       = module.core.resource_group_name
}

output "resource_group_id" {
  description = "ID of the resource group"
  value       = module.core.resource_group_id
}

output "virtual_wan_id" {
  description = "ID of the Virtual WAN"
  value       = module.core.virtual_wan_id
}

output "virtual_wan_name" {
  description = "Name of the Virtual WAN"
  value       = module.core.virtual_wan_name
}

#------------------------------------------------------------------------------
# Virtual Hubs
#------------------------------------------------------------------------------
output "primary_hub_id" {
  description = "ID of the primary Virtual Hub"
  value       = module.core.primary_hub_id
}

output "primary_hub_name" {
  description = "Name of the primary Virtual Hub"
  value       = module.core.primary_hub_name
}

output "secondary_hub_id" {
  description = "ID of the secondary Virtual Hub"
  value       = module.core.secondary_hub_id
}

output "secondary_hub_name" {
  description = "Name of the secondary Virtual Hub"
  value       = module.core.secondary_hub_name
}

#------------------------------------------------------------------------------
# VPN Gateways
#------------------------------------------------------------------------------
output "primary_vpn_gateway_id" {
  description = "ID of the primary VPN Gateway"
  value       = module.connectivity.primary_vpn_gateway_id
}

output "primary_vpn_gateway_name" {
  description = "Name of the primary VPN Gateway"
  value       = module.connectivity.primary_vpn_gateway_name
}

output "secondary_vpn_gateway_id" {
  description = "ID of the secondary VPN Gateway"
  value       = module.connectivity.secondary_vpn_gateway_id
}

output "secondary_vpn_gateway_name" {
  description = "Name of the secondary VPN Gateway"
  value       = module.connectivity.secondary_vpn_gateway_name
}

#------------------------------------------------------------------------------
# ExpressRoute Gateways
#------------------------------------------------------------------------------
output "primary_er_gateway_id" {
  description = "ID of the primary ExpressRoute Gateway"
  value       = module.connectivity.primary_er_gateway_id
}

output "primary_er_gateway_name" {
  description = "Name of the primary ExpressRoute Gateway"
  value       = module.connectivity.primary_er_gateway_name
}

output "secondary_er_gateway_id" {
  description = "ID of the secondary ExpressRoute Gateway"
  value       = module.connectivity.secondary_er_gateway_id
}

output "secondary_er_gateway_name" {
  description = "Name of the secondary ExpressRoute Gateway"
  value       = module.connectivity.secondary_er_gateway_name
}

#------------------------------------------------------------------------------
# Azure Firewall
#------------------------------------------------------------------------------
output "primary_firewall_id" {
  description = "ID of the primary Azure Firewall"
  value       = module.security.primary_firewall_id
}

output "primary_firewall_name" {
  description = "Name of the primary Azure Firewall"
  value       = module.security.primary_firewall_name
}

output "primary_firewall_private_ip" {
  description = "Private IP of the primary Azure Firewall"
  value       = module.security.primary_firewall_private_ip
}

output "secondary_firewall_id" {
  description = "ID of the secondary Azure Firewall"
  value       = module.security.secondary_firewall_id
}

output "secondary_firewall_name" {
  description = "Name of the secondary Azure Firewall"
  value       = module.security.secondary_firewall_name
}

output "secondary_firewall_private_ip" {
  description = "Private IP of the secondary Azure Firewall"
  value       = module.security.secondary_firewall_private_ip
}

#------------------------------------------------------------------------------
# Monitoring
#------------------------------------------------------------------------------
output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics Workspace"
  value       = module.monitoring.log_analytics_workspace_id
}

output "log_analytics_workspace_name" {
  description = "Name of the Log Analytics Workspace"
  value       = module.monitoring.log_analytics_workspace_name
}

output "log_analytics_workspace_key" {
  description = "Primary shared key of the Log Analytics Workspace"
  value       = module.monitoring.log_analytics_workspace_key
  sensitive   = true
}

#------------------------------------------------------------------------------
# Environment Summary
#------------------------------------------------------------------------------
output "environment_summary" {
  description = "Summary of the deployed environment"
  value = {
    environment          = local.environment
    primary_region       = var.azure.region
    secondary_region     = var.azure.secondary_region
    wan_type             = var.vwan.type
    vpn_enabled          = var.connectivity.enable_vpn_gateway
    expressroute_enabled = var.connectivity.enable_expressroute_gateway
    firewall_enabled     = var.security.enable_firewall
    firewall_sku         = var.security.firewall_sku_tier
  }
}
