#------------------------------------------------------------------------------
# Azure Virtual WAN Global - Production Environment Variables
#------------------------------------------------------------------------------
# All configuration is defined as grouped objects for cleaner module calls.
# Values are set in config/*.tfvars files.
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Project Configuration (project.tfvars)
#------------------------------------------------------------------------------
variable "solution" {
  description = "Solution identification and metadata"
  type = object({
    name          = string
    abbr          = string
    provider_name = string
    category_name = string
  })
}

variable "azure" {
  description = "Azure subscription and region configuration"
  type = object({
    subscription_id  = string
    tenant_id        = string
    region           = string
    secondary_region = string
  })
}

variable "ownership" {
  description = "Solution ownership and cost allocation"
  type = object({
    cost_center  = string
    owner_email  = string
    project_code = string
  })
}

#------------------------------------------------------------------------------
# Virtual WAN Configuration (vwan.tfvars)
#------------------------------------------------------------------------------
variable "vwan" {
  description = "Virtual WAN configuration"
  type = object({
    type                     = string
    allow_branch_to_branch   = bool
    office365_breakout       = string
    hub_sku                  = string
    hub_routing_preference   = string
    enable_secondary_hub     = bool
    primary_hub_prefix       = string
    secondary_hub_prefix     = optional(string, "")
    create_custom_route_tables = bool
  })
}

#------------------------------------------------------------------------------
# Connectivity Configuration (connectivity.tfvars)
#------------------------------------------------------------------------------
variable "connectivity" {
  description = "VPN and ExpressRoute connectivity configuration"
  type = object({
    enable_vpn_gateway          = bool
    vpn_gateway_scale_unit      = number
    vpn_routing_preference      = string
    vpn_bgp_asn                 = number
    vpn_bgp_peer_weight         = number
    enable_expressroute_gateway = bool
    er_gateway_scale_units      = number
    er_allow_non_vwan_traffic   = bool
    # Optional BGP settings computed from base values
    vpn_bgp_settings            = optional(object({
      asn         = number
      peer_weight = number
    }), null)
    vpn_bgp_settings_secondary  = optional(object({
      asn         = number
      peer_weight = number
    }), null)
  })
}

#------------------------------------------------------------------------------
# Security Configuration (security.tfvars)
#------------------------------------------------------------------------------
variable "security" {
  description = "Firewall and security configuration"
  type = object({
    enable_firewall           = bool
    firewall_sku_tier         = string
    firewall_public_ip_count  = number
    create_firewall_policy    = bool
    share_firewall_policy     = bool
    dns_proxy_enabled         = bool
    threat_intelligence_mode  = string
    intrusion_detection_mode  = string
    # Optional fields with defaults
    dns_servers               = optional(list(string), [])
    network_rule_collections  = optional(list(any), [])
    application_rule_collections = optional(list(any), [])
  })
}

#------------------------------------------------------------------------------
# Monitoring Configuration (monitoring.tfvars)
#------------------------------------------------------------------------------
variable "monitoring" {
  description = "Monitoring and observability configuration"
  type = object({
    log_analytics_sku      = string
    log_retention_days     = number
    enable_alerts          = bool
    alert_email            = string
    enable_network_watcher = bool
  })
}
