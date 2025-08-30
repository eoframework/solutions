# Azure Virtual WAN Global Network Variables

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "vwan-global"
}

variable "primary_region" {
  description = "Primary Azure region"
  type        = string
  default     = "East US"
}

variable "virtual_wan_type" {
  description = "Type of Virtual WAN (Basic or Standard)"
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Basic", "Standard"], var.virtual_wan_type)
    error_message = "Virtual WAN type must be either 'Basic' or 'Standard'."
  }
}

variable "allow_branch_to_branch_traffic" {
  description = "Allow branch to branch traffic"
  type        = bool
  default     = true
}

variable "virtual_hubs" {
  description = "Configuration for Virtual WAN hubs"
  type = map(object({
    location                     = string
    address_prefix               = string
    sku                         = optional(string, "Standard")
    deploy_vpn_gateway          = optional(bool, false)
    deploy_expressroute_gateway = optional(bool, false)
    deploy_p2s_gateway          = optional(bool, false)
    deploy_firewall             = optional(bool, false)
  }))
  default = {
    "eastus" = {
      location       = "East US"
      address_prefix = "10.1.0.0/16"
      sku           = "Standard"
      deploy_vpn_gateway          = true
      deploy_expressroute_gateway = true
      deploy_firewall             = true
    }
    "westus" = {
      location       = "West US"
      address_prefix = "10.2.0.0/16"
      sku           = "Standard"
      deploy_vpn_gateway = true
      deploy_firewall    = true
    }
    "westeurope" = {
      location       = "West Europe"
      address_prefix = "10.3.0.0/16"
      sku           = "Standard"
      deploy_vpn_gateway = true
      deploy_firewall    = true
    }
  }
}

variable "spoke_vnets" {
  description = "Configuration for spoke virtual networks"
  type = map(object({
    location                   = string
    address_space             = list(string)
    hub_key                   = string
    internet_security_enabled = optional(bool, true)
    deploy_nsg                = optional(bool, true)
    subnets = map(object({
      address_prefixes = list(string)
      associate_nsg    = optional(bool, true)
    }))
    routing = optional(object({
      associated_route_table_id = optional(string)
      propagated_route_tables = optional(object({
        labels          = optional(list(string))
        route_table_ids = optional(list(string))
      }))
      static_routes = optional(list(object({
        name                = string
        address_prefixes    = list(string)
        next_hop_ip_address = string
      })))
    }))
  }))
  default = {
    "prod-eastus" = {
      location      = "East US"
      address_space = ["10.10.0.0/16"]
      hub_key       = "eastus"
      subnets = {
        "web-subnet" = {
          address_prefixes = ["10.10.1.0/24"]
        }
        "app-subnet" = {
          address_prefixes = ["10.10.2.0/24"]
        }
        "data-subnet" = {
          address_prefixes = ["10.10.3.0/24"]
          associate_nsg    = true
        }
      }
    }
    "prod-westus" = {
      location      = "West US"
      address_space = ["10.20.0.0/16"]
      hub_key       = "westus"
      subnets = {
        "web-subnet" = {
          address_prefixes = ["10.20.1.0/24"]
        }
        "app-subnet" = {
          address_prefixes = ["10.20.2.0/24"]
        }
      }
    }
    "prod-westeurope" = {
      location      = "West Europe"
      address_space = ["10.30.0.0/16"]
      hub_key       = "westeurope"
      subnets = {
        "web-subnet" = {
          address_prefixes = ["10.30.1.0/24"]
        }
        "app-subnet" = {
          address_prefixes = ["10.30.2.0/24"]
        }
      }
    }
  }
}

variable "route_tables" {
  description = "Custom route tables configuration"
  type = map(object({
    hub_key = string
    labels  = list(string)
    routes = list(object({
      name              = string
      destinations_type = string
      destinations      = list(string)
      next_hop_type     = string
      next_hop          = string
    }))
  }))
  default = {}
}

variable "vpn_gateway_scale_unit" {
  description = "Scale units for VPN gateway"
  type        = number
  default     = 1
  validation {
    condition     = var.vpn_gateway_scale_unit >= 1 && var.vpn_gateway_scale_unit <= 20
    error_message = "VPN gateway scale units must be between 1 and 20."
  }
}

variable "expressroute_gateway_scale_units" {
  description = "Scale units for ExpressRoute gateway"
  type        = number
  default     = 1
  validation {
    condition     = var.expressroute_gateway_scale_units >= 1 && var.expressroute_gateway_scale_units <= 10
    error_message = "ExpressRoute gateway scale units must be between 1 and 10."
  }
}

variable "p2s_gateway_scale_unit" {
  description = "Scale unit for Point-to-Site VPN gateway"
  type        = number
  default     = 1
  validation {
    condition     = var.p2s_gateway_scale_unit >= 1 && var.p2s_gateway_scale_unit <= 20
    error_message = "P2S gateway scale units must be between 1 and 20."
  }
}

variable "p2s_address_pools" {
  description = "Address pools for Point-to-Site VPN clients"
  type        = list(string)
  default     = ["172.16.0.0/24"]
}

variable "p2s_root_certificate" {
  description = "Root certificate data for P2S authentication"
  type        = string
  default     = ""
}

variable "deploy_azure_firewall" {
  description = "Deploy Azure Firewall in hubs"
  type        = bool
  default     = true
}

variable "firewall_sku_tier" {
  description = "Azure Firewall SKU tier"
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.firewall_sku_tier)
    error_message = "Firewall SKU tier must be Basic, Standard, or Premium."
  }
}

variable "firewall_policy_sku" {
  description = "Azure Firewall Policy SKU"
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.firewall_policy_sku)
    error_message = "Firewall Policy SKU must be Basic, Standard, or Premium."
  }
}

variable "firewall_public_ip_count" {
  description = "Number of public IPs for Azure Firewall"
  type        = number
  default     = 1
  validation {
    condition     = var.firewall_public_ip_count >= 1 && var.firewall_public_ip_count <= 100
    error_message = "Firewall public IP count must be between 1 and 100."
  }
}

variable "threat_intelligence_mode" {
  description = "Threat intelligence mode for firewall policy"
  type        = string
  default     = "Alert"
  validation {
    condition     = contains(["Off", "Alert", "Deny"], var.threat_intelligence_mode)
    error_message = "Threat intelligence mode must be Off, Alert, or Deny."
  }
}

variable "custom_dns_servers" {
  description = "Custom DNS servers for firewall policy"
  type        = list(string)
  default     = []
}

variable "enable_monitoring" {
  description = "Enable monitoring with Log Analytics"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "Log Analytics workspace retention in days"
  type        = number
  default     = 30
  validation {
    condition     = var.log_retention_days >= 30 && var.log_retention_days <= 730
    error_message = "Log retention must be between 30 and 730 days."
  }
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "Virtual WAN Global"
    Environment = "Production"
    ManagedBy   = "Terraform"
    Owner       = "Network Team"
  }
}

# Security and Compliance
variable "enable_ddos_protection" {
  description = "Enable DDoS protection"
  type        = bool
  default     = false
}

variable "ddos_protection_plan_id" {
  description = "DDoS protection plan ID if enabled"
  type        = string
  default     = ""
}

# Network Security Groups
variable "default_nsg_rules" {
  description = "Default NSG rules for spoke VNets"
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
  default = [
    {
      name                       = "Allow-HTTP-Inbound"
      priority                   = 1000
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "80"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    {
      name                       = "Allow-HTTPS-Inbound"
      priority                   = 1001
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  ]
}

# Backup and Recovery
variable "enable_backup" {
  description = "Enable backup for network configurations"
  type        = bool
  default     = true
}

variable "backup_retention_days" {
  description = "Backup retention period in days"
  type        = number
  default     = 30
}

# Cost Optimization
variable "enable_cost_optimization" {
  description = "Enable cost optimization features"
  type        = bool
  default     = true
}

variable "auto_shutdown_enabled" {
  description = "Enable automatic shutdown for development resources"
  type        = bool
  default     = false
}

# Performance and Scaling
variable "enable_accelerated_networking" {
  description = "Enable accelerated networking where supported"
  type        = bool
  default     = true
}

variable "bandwidth_mbps" {
  description = "Bandwidth in Mbps for ExpressRoute connections"
  type        = number
  default     = 1000
  validation {
    condition = contains([
      50, 100, 200, 500, 1000, 2000, 5000, 10000
    ], var.bandwidth_mbps)
    error_message = "Bandwidth must be one of: 50, 100, 200, 500, 1000, 2000, 5000, 10000 Mbps."
  }
}