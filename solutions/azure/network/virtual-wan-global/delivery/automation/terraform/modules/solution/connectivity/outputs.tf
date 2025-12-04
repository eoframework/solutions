#------------------------------------------------------------------------------
# Virtual WAN Connectivity Module Outputs
#------------------------------------------------------------------------------

output "primary_vpn_gateway_id" {
  description = "ID of the primary VPN Gateway"
  value       = var.enable_vpn_gateway ? module.primary_vpn_gateway[0].id : null
}

output "primary_vpn_gateway_name" {
  description = "Name of the primary VPN Gateway"
  value       = var.enable_vpn_gateway ? module.primary_vpn_gateway[0].name : null
}

output "secondary_vpn_gateway_id" {
  description = "ID of the secondary VPN Gateway"
  value       = var.enable_vpn_gateway && var.enable_secondary_hub ? module.secondary_vpn_gateway[0].id : null
}

output "secondary_vpn_gateway_name" {
  description = "Name of the secondary VPN Gateway"
  value       = var.enable_vpn_gateway && var.enable_secondary_hub ? module.secondary_vpn_gateway[0].name : null
}

output "primary_er_gateway_id" {
  description = "ID of the primary ExpressRoute Gateway"
  value       = var.enable_expressroute_gateway ? module.primary_er_gateway[0].id : null
}

output "primary_er_gateway_name" {
  description = "Name of the primary ExpressRoute Gateway"
  value       = var.enable_expressroute_gateway ? module.primary_er_gateway[0].name : null
}

output "secondary_er_gateway_id" {
  description = "ID of the secondary ExpressRoute Gateway"
  value       = var.enable_expressroute_gateway && var.enable_secondary_hub ? module.secondary_er_gateway[0].id : null
}

output "secondary_er_gateway_name" {
  description = "Name of the secondary ExpressRoute Gateway"
  value       = var.enable_expressroute_gateway && var.enable_secondary_hub ? module.secondary_er_gateway[0].name : null
}
