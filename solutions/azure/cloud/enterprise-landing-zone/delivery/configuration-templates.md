# Azure Enterprise Landing Zone - Configuration Templates

## Overview

This document provides comprehensive Infrastructure as Code (IaC) templates for deploying the Azure Enterprise Landing Zone. These templates include Terraform configurations, ARM templates, Azure Bicep files, and configuration scripts that enable automated and repeatable deployments.

**Template Categories:**
- Terraform HCL configurations for multi-cloud compatibility
- ARM templates for Azure-native deployment
- Azure Bicep for simplified Azure resource definitions
- PowerShell and CLI scripts for automation
- Policy definitions and initiatives

## Terraform Configuration Templates

### Main Terraform Configuration

**File: `main.tf`**
```hcl
terraform {
  required_version = ">= 1.2.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.0"
    }
  }
  
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "stterraformstate001"
    container_name       = "tfstate"
    key                  = "enterprise-landing-zone.tfstate"
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

provider "azurerm" {
  alias           = "connectivity"
  subscription_id = var.connectivity_subscription_id
  features {}
}

provider "azurerm" {
  alias           = "management"
  subscription_id = var.management_subscription_id
  features {}
}

provider "azurerm" {
  alias           = "identity"
  subscription_id = var.identity_subscription_id
  features {}
}

data "azurerm_client_config" "current" {}

# Local values for consistent naming
locals {
  location_short = {
    "East US"       = "eus"
    "East US 2"     = "eus2"
    "West US"       = "wus"
    "West US 2"     = "wus2"
    "Central US"    = "cus"
    "North Central US" = "ncus"
    "South Central US" = "scus"
    "West Central US"  = "wcus"
  }
  
  environment_short = {
    "Production"    = "prod"
    "Staging"       = "stg"
    "Development"   = "dev"
    "Testing"       = "test"
    "Sandbox"       = "sbx"
  }
  
  common_tags = {
    Environment   = var.environment
    Owner         = var.owner
    CostCenter    = var.cost_center
    Project       = "Enterprise Landing Zone"
    DeployedBy    = "Terraform"
    DeployedDate  = timestamp()
  }
}

# Management Groups
resource "azurerm_management_group" "enterprise_root" {
  name         = var.management_group_prefix
  display_name = "${var.organization_name} Root"
}

resource "azurerm_management_group" "platform" {
  name                   = "${var.management_group_prefix}-platform"
  display_name          = "Platform"
  parent_management_group_id = azurerm_management_group.enterprise_root.id
}

resource "azurerm_management_group" "landing_zones" {
  name                   = "${var.management_group_prefix}-landingzones"
  display_name          = "Landing Zones"
  parent_management_group_id = azurerm_management_group.enterprise_root.id
}

resource "azurerm_management_group" "platform_identity" {
  name                   = "${var.management_group_prefix}-platform-identity"
  display_name          = "Platform Identity"
  parent_management_group_id = azurerm_management_group.platform.id
}

resource "azurerm_management_group" "platform_management" {
  name                   = "${var.management_group_prefix}-platform-management"
  display_name          = "Platform Management"
  parent_management_group_id = azurerm_management_group.platform.id
}

resource "azurerm_management_group" "platform_connectivity" {
  name                   = "${var.management_group_prefix}-platform-connectivity"
  display_name          = "Platform Connectivity"
  parent_management_group_id = azurerm_management_group.platform.id
}

resource "azurerm_management_group" "corp_landing_zones" {
  name                   = "${var.management_group_prefix}-landingzones-corp"
  display_name          = "Corporate Landing Zones"
  parent_management_group_id = azurerm_management_group.landing_zones.id
}

resource "azurerm_management_group" "online_landing_zones" {
  name                   = "${var.management_group_prefix}-landingzones-online"
  display_name          = "Online Landing Zones"
  parent_management_group_id = azurerm_management_group.landing_zones.id
}

resource "azurerm_management_group" "sandbox" {
  name                   = "${var.management_group_prefix}-sandbox"
  display_name          = "Sandbox"
  parent_management_group_id = azurerm_management_group.enterprise_root.id
}

resource "azurerm_management_group" "decommissioned" {
  name                   = "${var.management_group_prefix}-decommissioned"
  display_name          = "Decommissioned"
  parent_management_group_id = azurerm_management_group.enterprise_root.id
}

# Call modules for each platform component
module "connectivity" {
  source = "./modules/connectivity"
  
  resource_group_name     = "rg-connectivity-${local.environment_short[var.environment]}-${local.location_short[var.location]}-001"
  location               = var.location
  hub_vnet_address_space = var.hub_vnet_address_space
  
  enable_expressroute    = var.enable_expressroute
  enable_vpn_gateway     = var.enable_vpn_gateway
  enable_azure_firewall  = var.enable_azure_firewall
  enable_bastion         = var.enable_bastion
  
  tags = local.common_tags
  
  providers = {
    azurerm = azurerm.connectivity
  }
}

module "management" {
  source = "./modules/management"
  
  resource_group_name = "rg-management-${local.environment_short[var.environment]}-${local.location_short[var.location]}-001"
  location           = var.location
  
  log_analytics_retention_days = var.log_analytics_retention_days
  
  tags = local.common_tags
  
  providers = {
    azurerm = azurerm.management
  }
}

module "identity" {
  source = "./modules/identity"
  
  resource_group_name = "rg-identity-${local.environment_short[var.environment]}-${local.location_short[var.location]}-001"
  location           = var.location
  
  identity_vnet_address_space = var.identity_vnet_address_space
  
  tags = local.common_tags
  
  providers = {
    azurerm = azurerm.identity
  }
}

module "landing_zones" {
  source = "./modules/landing-zones"
  
  location                    = var.location
  hub_vnet_id                = module.connectivity.hub_vnet_id
  connectivity_subscription_id = var.connectivity_subscription_id
  
  corp_vnet_address_space     = var.corp_vnet_address_space
  online_vnet_address_space   = var.online_vnet_address_space
  
  tags = local.common_tags
}

# Policy assignments
module "policies" {
  source = "./modules/policies"
  
  management_group_id = azurerm_management_group.enterprise_root.id
  log_analytics_workspace_id = module.management.log_analytics_workspace_id
  
  depends_on = [
    azurerm_management_group.enterprise_root,
    module.management
  ]
}
```

### Variables Configuration

**File: `variables.tf`**
```hcl
# Organization and Environment Variables
variable "organization_name" {
  description = "Name of the organization"
  type        = string
  default     = "Contoso"
}

variable "environment" {
  description = "Environment name (Production, Staging, Development, etc.)"
  type        = string
  default     = "Production"
  
  validation {
    condition = contains(["Production", "Staging", "Development", "Testing", "Sandbox"], var.environment)
    error_message = "Environment must be one of: Production, Staging, Development, Testing, Sandbox."
  }
}

variable "location" {
  description = "Azure region for resource deployment"
  type        = string
  default     = "East US 2"
}

variable "owner" {
  description = "Owner of the resources"
  type        = string
  default     = "Platform Team"
}

variable "cost_center" {
  description = "Cost center for resource billing"
  type        = string
  default     = "IT-Infrastructure"
}

# Management Group Configuration
variable "management_group_prefix" {
  description = "Prefix for management group naming"
  type        = string
  default     = "mg-enterprise"
}

# Subscription IDs
variable "connectivity_subscription_id" {
  description = "Subscription ID for connectivity platform"
  type        = string
}

variable "management_subscription_id" {
  description = "Subscription ID for management platform"
  type        = string
}

variable "identity_subscription_id" {
  description = "Subscription ID for identity platform"
  type        = string
}

# Network Configuration
variable "hub_vnet_address_space" {
  description = "Address space for hub virtual network"
  type        = list(string)
  default     = ["10.10.0.0/16"]
}

variable "identity_vnet_address_space" {
  description = "Address space for identity virtual network"
  type        = list(string)
  default     = ["10.0.0.0/24"]
}

variable "corp_vnet_address_space" {
  description = "Address space for corporate landing zone virtual network"
  type        = list(string)
  default     = ["10.20.0.0/16"]
}

variable "online_vnet_address_space" {
  description = "Address space for online landing zone virtual network"
  type        = list(string)
  default     = ["10.30.0.0/16"]
}

# Feature Flags
variable "enable_expressroute" {
  description = "Enable ExpressRoute gateway deployment"
  type        = bool
  default     = false
}

variable "enable_vpn_gateway" {
  description = "Enable VPN gateway deployment"
  type        = bool
  default     = true
}

variable "enable_azure_firewall" {
  description = "Enable Azure Firewall deployment"
  type        = bool
  default     = true
}

variable "enable_bastion" {
  description = "Enable Azure Bastion deployment"
  type        = bool
  default     = true
}

# Management Configuration
variable "log_analytics_retention_days" {
  description = "Log Analytics workspace retention in days"
  type        = number
  default     = 90
  
  validation {
    condition     = var.log_analytics_retention_days >= 30 && var.log_analytics_retention_days <= 730
    error_message = "Log Analytics retention must be between 30 and 730 days."
  }
}

# ExpressRoute Configuration
variable "expressroute_sku" {
  description = "ExpressRoute gateway SKU"
  type        = string
  default     = "Standard"
  
  validation {
    condition     = contains(["Standard", "HighPerformance", "UltraPerformance"], var.expressroute_sku)
    error_message = "ExpressRoute SKU must be Standard, HighPerformance, or UltraPerformance."
  }
}

# VPN Configuration
variable "vpn_gateway_sku" {
  description = "VPN gateway SKU"
  type        = string
  default     = "VpnGw1"
  
  validation {
    condition     = contains(["VpnGw1", "VpnGw2", "VpnGw3", "VpnGw4", "VpnGw5"], var.vpn_gateway_sku)
    error_message = "VPN gateway SKU must be VpnGw1, VpnGw2, VpnGw3, VpnGw4, or VpnGw5."
  }
}

# Firewall Configuration
variable "firewall_sku_name" {
  description = "Azure Firewall SKU name"
  type        = string
  default     = "AZFW_VNet"
  
  validation {
    condition     = contains(["AZFW_VNet", "AZFW_Hub"], var.firewall_sku_name)
    error_message = "Firewall SKU name must be AZFW_VNet or AZFW_Hub."
  }
}

variable "firewall_sku_tier" {
  description = "Azure Firewall SKU tier"
  type        = string
  default     = "Standard"
  
  validation {
    condition     = contains(["Standard", "Premium"], var.firewall_sku_tier)
    error_message = "Firewall SKU tier must be Standard or Premium."
  }
}
```

### Connectivity Module

**File: `modules/connectivity/main.tf`**
```hcl
# Connectivity Platform Resources
resource "azurerm_resource_group" "connectivity" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# Hub Virtual Network
resource "azurerm_virtual_network" "hub_vnet" {
  name                = "vnet-hub-${var.environment}-${var.location_short}-001"
  address_space       = var.hub_vnet_address_space
  location            = azurerm_resource_group.connectivity.location
  resource_group_name = azurerm_resource_group.connectivity.name
  tags                = var.tags
}

# Gateway Subnet
resource "azurerm_subnet" "gateway_subnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.connectivity.name
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  address_prefixes     = [cidrsubnet(var.hub_vnet_address_space[0], 8, 0)]
}

# Azure Firewall Subnet
resource "azurerm_subnet" "firewall_subnet" {
  count                = var.enable_azure_firewall ? 1 : 0
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.connectivity.name
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  address_prefixes     = [cidrsubnet(var.hub_vnet_address_space[0], 8, 1)]
}

# Bastion Subnet
resource "azurerm_subnet" "bastion_subnet" {
  count                = var.enable_bastion ? 1 : 0
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.connectivity.name
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  address_prefixes     = [cidrsubnet(var.hub_vnet_address_space[0], 8, 2)]
}

# Azure Firewall Public IP
resource "azurerm_public_ip" "firewall_pip" {
  count               = var.enable_azure_firewall ? 1 : 0
  name                = "pip-firewall-${var.environment}-${var.location_short}-001"
  location            = azurerm_resource_group.connectivity.location
  resource_group_name = azurerm_resource_group.connectivity.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

# Azure Firewall
resource "azurerm_firewall" "hub_firewall" {
  count               = var.enable_azure_firewall ? 1 : 0
  name                = "afw-hub-${var.environment}-${var.location_short}-001"
  location            = azurerm_resource_group.connectivity.location
  resource_group_name = azurerm_resource_group.connectivity.name
  sku_name           = var.firewall_sku_name
  sku_tier           = var.firewall_sku_tier
  
  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.firewall_subnet[0].id
    public_ip_address_id = azurerm_public_ip.firewall_pip[0].id
  }
  
  tags = var.tags
}

# VPN Gateway Public IP
resource "azurerm_public_ip" "vpn_gateway_pip" {
  count               = var.enable_vpn_gateway ? 1 : 0
  name                = "pip-vpn-gateway-${var.environment}-${var.location_short}-001"
  location            = azurerm_resource_group.connectivity.location
  resource_group_name = azurerm_resource_group.connectivity.name
  allocation_method   = "Dynamic"
  tags                = var.tags
}

# VPN Gateway
resource "azurerm_virtual_network_gateway" "vpn_gateway" {
  count               = var.enable_vpn_gateway ? 1 : 0
  name                = "vgw-vpn-${var.environment}-${var.location_short}-001"
  location            = azurerm_resource_group.connectivity.location
  resource_group_name = azurerm_resource_group.connectivity.name
  
  type     = "Vpn"
  vpn_type = "RouteBased"
  
  active_active = false
  enable_bgp    = true
  sku           = var.vpn_gateway_sku
  
  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.vpn_gateway_pip[0].id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.gateway_subnet.id
  }
  
  bgp_settings {
    asn = 65515
  }
  
  tags = var.tags
}

# ExpressRoute Gateway Public IP
resource "azurerm_public_ip" "expressroute_gateway_pip" {
  count               = var.enable_expressroute ? 1 : 0
  name                = "pip-er-gateway-${var.environment}-${var.location_short}-001"
  location            = azurerm_resource_group.connectivity.location
  resource_group_name = azurerm_resource_group.connectivity.name
  allocation_method   = "Dynamic"
  tags                = var.tags
}

# ExpressRoute Gateway
resource "azurerm_virtual_network_gateway" "expressroute_gateway" {
  count               = var.enable_expressroute ? 1 : 0
  name                = "vgw-er-${var.environment}-${var.location_short}-001"
  location            = azurerm_resource_group.connectivity.location
  resource_group_name = azurerm_resource_group.connectivity.name
  
  type = "ExpressRoute"
  sku  = var.expressroute_sku
  
  ip_configuration {
    name                          = "erGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.expressroute_gateway_pip[0].id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.gateway_subnet.id
  }
  
  tags = var.tags
}

# Bastion Public IP
resource "azurerm_public_ip" "bastion_pip" {
  count               = var.enable_bastion ? 1 : 0
  name                = "pip-bastion-${var.environment}-${var.location_short}-001"
  location            = azurerm_resource_group.connectivity.location
  resource_group_name = azurerm_resource_group.connectivity.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

# Azure Bastion
resource "azurerm_bastion_host" "bastion" {
  count               = var.enable_bastion ? 1 : 0
  name                = "bas-${var.environment}-${var.location_short}-001"
  location            = azurerm_resource_group.connectivity.location
  resource_group_name = azurerm_resource_group.connectivity.name
  
  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastion_subnet[0].id
    public_ip_address_id = azurerm_public_ip.bastion_pip[0].id
  }
  
  tags = var.tags
}

# Route Tables
resource "azurerm_route_table" "spoke_rt" {
  name                = "rt-spoke-${var.environment}-${var.location_short}-001"
  location            = azurerm_resource_group.connectivity.location
  resource_group_name = azurerm_resource_group.connectivity.name
  
  dynamic "route" {
    for_each = var.enable_azure_firewall ? [1] : []
    content {
      name                   = "default-route"
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = azurerm_firewall.hub_firewall[0].ip_configuration[0].private_ip_address
    }
  }
  
  tags = var.tags
}

# Network Security Groups
resource "azurerm_network_security_group" "hub_nsg" {
  name                = "nsg-hub-${var.environment}-${var.location_short}-001"
  location            = azurerm_resource_group.connectivity.location
  resource_group_name = azurerm_resource_group.connectivity.name
  
  security_rule {
    name                       = "AllowAzureCloudOutbound"
    priority                   = 1000
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "AzureCloud"
  }
  
  security_rule {
    name                       = "AllowInternetOutbound"
    priority                   = 1001
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "Internet"
  }
  
  tags = var.tags
}
```

### Management Module

**File: `modules/management/main.tf`**
```hcl
# Management Platform Resources
resource "azurerm_resource_group" "management" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "management" {
  name                = "law-management-${var.environment}-${var.location_short}-001"
  location            = azurerm_resource_group.management.location
  resource_group_name = azurerm_resource_group.management.name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_analytics_retention_days
  
  tags = var.tags
}

# Log Analytics Solutions
resource "azurerm_log_analytics_solution" "security" {
  solution_name         = "Security"
  location              = azurerm_resource_group.management.location
  resource_group_name   = azurerm_resource_group.management.name
  workspace_resource_id = azurerm_log_analytics_workspace.management.id
  workspace_name        = azurerm_log_analytics_workspace.management.name
  
  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/Security"
  }
  
  tags = var.tags
}

resource "azurerm_log_analytics_solution" "updates" {
  solution_name         = "Updates"
  location              = azurerm_resource_group.management.location
  resource_group_name   = azurerm_resource_group.management.name
  workspace_resource_id = azurerm_log_analytics_workspace.management.id
  workspace_name        = azurerm_log_analytics_workspace.management.name
  
  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/Updates"
  }
  
  tags = var.tags
}

resource "azurerm_log_analytics_solution" "vminsights" {
  solution_name         = "VMInsights"
  location              = azurerm_resource_group.management.location
  resource_group_name   = azurerm_resource_group.management.name
  workspace_resource_id = azurerm_log_analytics_workspace.management.id
  workspace_name        = azurerm_log_analytics_workspace.management.name
  
  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/VMInsights"
  }
  
  tags = var.tags
}

# Automation Account
resource "azurerm_automation_account" "management" {
  name                = "aa-management-${var.environment}-${var.location_short}-001"
  location            = azurerm_resource_group.management.location
  resource_group_name = azurerm_resource_group.management.name
  sku_name           = "Basic"
  
  tags = var.tags
}

# Link Automation Account to Log Analytics
resource "azurerm_log_analytics_linked_service" "management" {
  resource_group_name = azurerm_resource_group.management.name
  workspace_id        = azurerm_log_analytics_workspace.management.id
  read_access_id      = azurerm_automation_account.management.id
}

# Recovery Services Vault
resource "azurerm_recovery_services_vault" "management" {
  name                = "rsv-management-${var.environment}-${var.location_short}-001"
  location            = azurerm_resource_group.management.location
  resource_group_name = azurerm_resource_group.management.name
  sku                 = "Standard"
  
  soft_delete_enabled = true
  
  tags = var.tags
}

# Storage Account for Diagnostics
resource "azurerm_storage_account" "diagnostics" {
  name                     = "stdiag${var.environment}${var.location_short}001"
  resource_group_name      = azurerm_resource_group.management.name
  location                 = azurerm_resource_group.management.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  
  blob_properties {
    delete_retention_policy {
      days = 7
    }
  }
  
  tags = var.tags
}

# Key Vault for Secrets Management
resource "azurerm_key_vault" "management" {
  name                = "kv-mgmt-${var.environment}-${var.location_short}-001"
  location            = azurerm_resource_group.management.location
  resource_group_name = azurerm_resource_group.management.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  
  sku_name = "premium"
  
  enable_rbac_authorization = true
  
  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
  }
  
  tags = var.tags
}

# Action Groups for Alerting
resource "azurerm_monitor_action_group" "main" {
  name                = "ag-platform-alerts-${var.environment}-${var.location_short}-001"
  resource_group_name = azurerm_resource_group.management.name
  short_name          = "platform"
  
  email_receiver {
    name          = "platform-team"
    email_address = var.alert_email_address
  }
  
  tags = var.tags
}

# Data Collection Rules
resource "azurerm_monitor_data_collection_rule" "vm_insights" {
  name                = "dcr-vm-insights-${var.environment}-${var.location_short}-001"
  resource_group_name = azurerm_resource_group.management.name
  location            = azurerm_resource_group.management.location
  
  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.management.id
      name                  = "destination-log"
    }
  }
  
  data_flow {
    streams      = ["Microsoft-InsightsMetrics", "Microsoft-ServiceMap"]
    destinations = ["destination-log"]
  }
  
  data_sources {
    performance_counter {
      streams                       = ["Microsoft-InsightsMetrics"]
      sampling_frequency_in_seconds = 60
      counter_specifiers           = ["\\Processor Information(_Total)\\% Processor Time", "\\Memory\\Available Bytes", "\\Network Interface(*)\\Bytes Total/sec"]
      name                         = "perfCounterDataSource60"
    }
  }
  
  tags = var.tags
}
```

## ARM Templates

### Main Deployment Template

**File: `azuredeploy.json`**
```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "organizationName": {
      "type": "string",
      "defaultValue": "Contoso",
      "metadata": {
        "description": "Name of the organization"
      }
    },
    "environment": {
      "type": "string",
      "defaultValue": "Production",
      "allowedValues": [
        "Production",
        "Staging", 
        "Development",
        "Testing",
        "Sandbox"
      ],
      "metadata": {
        "description": "Environment name"
      }
    },
    "location": {
      "type": "string",
      "defaultValue": "[resourceGroup().location]",
      "metadata": {
        "description": "Location for all resources"
      }
    },
    "hubVnetAddressSpace": {
      "type": "string",
      "defaultValue": "10.10.0.0/16",
      "metadata": {
        "description": "Address space for hub virtual network"
      }
    },
    "enableAzureFirewall": {
      "type": "bool",
      "defaultValue": true,
      "metadata": {
        "description": "Enable Azure Firewall deployment"
      }
    },
    "enableVpnGateway": {
      "type": "bool", 
      "defaultValue": true,
      "metadata": {
        "description": "Enable VPN Gateway deployment"
      }
    },
    "enableBastion": {
      "type": "bool",
      "defaultValue": true,
      "metadata": {
        "description": "Enable Azure Bastion deployment"
      }
    }
  },
  "variables": {
    "locationShort": {
      "East US": "eus",
      "East US 2": "eus2",
      "West US": "wus",
      "West US 2": "wus2",
      "Central US": "cus"
    },
    "environmentShort": {
      "Production": "prod",
      "Staging": "stg", 
      "Development": "dev",
      "Testing": "test",
      "Sandbox": "sbx"
    },
    "resourceSuffix": "[concat(variables('environmentShort')[parameters('environment')], '-', variables('locationShort')[parameters('location')], '-001')]",
    "hubVnetName": "[concat('vnet-hub-', variables('resourceSuffix'))]",
    "firewallName": "[concat('afw-hub-', variables('resourceSuffix'))]",
    "bastionName": "[concat('bas-', variables('resourceSuffix'))]",
    "vpnGatewayName": "[concat('vgw-vpn-', variables('resourceSuffix'))]"
  },
  "resources": [
    {
      "type": "Microsoft.Network/virtualNetworks",
      "apiVersion": "2021-05-01",
      "name": "[variables('hubVnetName')]",
      "location": "[parameters('location')]",
      "properties": {
        "addressSpace": {
          "addressPrefixes": [
            "[parameters('hubVnetAddressSpace')]"
          ]
        },
        "subnets": [
          {
            "name": "GatewaySubnet",
            "properties": {
              "addressPrefix": "[concat(split(parameters('hubVnetAddressSpace'), '/')[0], '/', '24')]"
            }
          },
          {
            "name": "AzureFirewallSubnet",
            "properties": {
              "addressPrefix": "[concat(split(parameters('hubVnetAddressSpace'), '/')[0], '/', '24')]"
            },
            "condition": "[parameters('enableAzureFirewall')]"
          },
          {
            "name": "AzureBastionSubnet", 
            "properties": {
              "addressPrefix": "[concat(split(parameters('hubVnetAddressSpace'), '/')[0], '/', '24')]"
            },
            "condition": "[parameters('enableBastion')]"
          }
        ]
      },
      "tags": {
        "Environment": "[parameters('environment')]",
        "Owner": "Platform Team",
        "CostCenter": "IT-Infrastructure"
      }
    }
  ],
  "outputs": {
    "hubVnetId": {
      "type": "string",
      "value": "[resourceId('Microsoft.Network/virtualNetworks', variables('hubVnetName'))]"
    },
    "hubVnetName": {
      "type": "string", 
      "value": "[variables('hubVnetName')]"
    }
  }
}
```

## Azure Bicep Templates

### Main Bicep Configuration

**File: `main.bicep`**
```bicep
@description('Organization name')
param organizationName string = 'Contoso'

@description('Environment name')
@allowed([
  'Production'
  'Staging'
  'Development'
  'Testing'
  'Sandbox'
])
param environment string = 'Production'

@description('Primary location for resources')
param location string = resourceGroup().location

@description('Hub VNet address space')
param hubVnetAddressSpace string = '10.10.0.0/16'

@description('Enable Azure Firewall')
param enableAzureFirewall bool = true

@description('Enable VPN Gateway')
param enableVpnGateway bool = true

@description('Enable Azure Bastion')
param enableBastion bool = true

@description('Log Analytics retention days')
@minValue(30)
@maxValue(730)
param logAnalyticsRetentionDays int = 90

// Variables
var locationShort = {
  'East US': 'eus'
  'East US 2': 'eus2'
  'West US': 'wus'
  'West US 2': 'wus2'
  'Central US': 'cus'
}

var environmentShort = {
  'Production': 'prod'
  'Staging': 'stg'
  'Development': 'dev'
  'Testing': 'test'
  'Sandbox': 'sbx'
}

var resourceSuffix = '${environmentShort[environment]}-${locationShort[location]}-001'
var commonTags = {
  Environment: environment
  Owner: 'Platform Team'
  CostCenter: 'IT-Infrastructure'
  Project: 'Enterprise Landing Zone'
}

// Connectivity Module
module connectivity 'modules/connectivity.bicep' = {
  name: 'connectivity-deployment'
  params: {
    location: location
    resourceSuffix: resourceSuffix
    hubVnetAddressSpace: hubVnetAddressSpace
    enableAzureFirewall: enableAzureFirewall
    enableVpnGateway: enableVpnGateway
    enableBastion: enableBastion
    tags: commonTags
  }
}

// Management Module
module management 'modules/management.bicep' = {
  name: 'management-deployment'
  params: {
    location: location
    resourceSuffix: resourceSuffix
    logAnalyticsRetentionDays: logAnalyticsRetentionDays
    tags: commonTags
  }
}

// Identity Module
module identity 'modules/identity.bicep' = {
  name: 'identity-deployment'
  params: {
    location: location
    resourceSuffix: resourceSuffix
    tags: commonTags
  }
}

// Outputs
output hubVnetId string = connectivity.outputs.hubVnetId
output logAnalyticsWorkspaceId string = management.outputs.logAnalyticsWorkspaceId
output keyVaultId string = management.outputs.keyVaultId
```

## PowerShell Deployment Scripts

### Main Deployment Script

**File: `Deploy-EnterpriseLanguageZone.ps1`**
```powershell
<#
.SYNOPSIS
    Deploy Azure Enterprise Landing Zone using Infrastructure as Code
.DESCRIPTION
    This script deploys the complete Azure Enterprise Landing Zone infrastructure
    using Terraform, ARM templates, or Azure Bicep based on the specified deployment method.
.PARAMETER DeploymentMethod
    Deployment method to use: Terraform, ARM, or Bicep
.PARAMETER ConfigFile
    Path to configuration file (JSON format)
.PARAMETER Environment
    Target environment: Production, Staging, Development, Testing, or Sandbox
.PARAMETER Location
    Azure region for deployment
.EXAMPLE
    ./Deploy-EnterpriseLanguageZone.ps1 -DeploymentMethod Terraform -Environment Production -Location "East US 2"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateSet("Terraform", "ARM", "Bicep")]
    [string]$DeploymentMethod,
    
    [Parameter()]
    [string]$ConfigFile = "config.json",
    
    [Parameter()]
    [ValidateSet("Production", "Staging", "Development", "Testing", "Sandbox")]
    [string]$Environment = "Production",
    
    [Parameter()]
    [string]$Location = "East US 2",
    
    [Parameter()]
    [switch]$WhatIf
)

# Import required modules
Import-Module Az.Accounts -Force
Import-Module Az.Resources -Force
Import-Module Az.Profile -Force

# Global variables
$ErrorActionPreference = "Stop"
$script:LogFile = "deployment-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"

# Logging function
function Write-Log {
    param(
        [Parameter(Mandatory)]
        [string]$Message,
        
        [Parameter()]
        [ValidateSet("INFO", "WARNING", "ERROR")]
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    Write-Host $logMessage
    Add-Content -Path $script:LogFile -Value $logMessage
}

# Function to validate prerequisites
function Test-Prerequisites {
    Write-Log "Validating prerequisites..."
    
    # Check Azure CLI
    try {
        $azVersion = az version --output json | ConvertFrom-Json
        Write-Log "Azure CLI version: $($azVersion.'azure-cli')"
    }
    catch {
        throw "Azure CLI is not installed or not in PATH"
    }
    
    # Check PowerShell modules
    $requiredModules = @("Az.Accounts", "Az.Resources", "Az.Profile")
    foreach ($module in $requiredModules) {
        if (!(Get-Module -Name $module -ListAvailable)) {
            throw "Required PowerShell module '$module' is not installed"
        }
    }
    
    # Check deployment method tools
    switch ($DeploymentMethod) {
        "Terraform" {
            try {
                $tfVersion = terraform version
                Write-Log "Terraform version: $tfVersion"
            }
            catch {
                throw "Terraform is not installed or not in PATH"
            }
        }
        "Bicep" {
            try {
                $bicepVersion = az bicep version
                Write-Log "Bicep version: $bicepVersion"
            }
            catch {
                throw "Bicep is not installed"
            }
        }
    }
    
    Write-Log "Prerequisites validation completed successfully"
}

# Function to load configuration
function Get-Configuration {
    param([string]$ConfigPath)
    
    Write-Log "Loading configuration from: $ConfigPath"
    
    if (!(Test-Path $ConfigPath)) {
        throw "Configuration file not found: $ConfigPath"
    }
    
    try {
        $config = Get-Content -Path $ConfigPath | ConvertFrom-Json
        Write-Log "Configuration loaded successfully"
        return $config
    }
    catch {
        throw "Failed to parse configuration file: $($_.Exception.Message)"
    }
}

# Function to authenticate to Azure
function Connect-AzureAccount {
    param($Config)
    
    Write-Log "Authenticating to Azure..."
    
    try {
        # Check if already authenticated
        $context = Get-AzContext
        if ($context) {
            Write-Log "Already authenticated as: $($context.Account.Id)"
            return
        }
        
        # Interactive authentication
        Connect-AzAccount
        
        # Set subscription context
        if ($Config.SubscriptionId) {
            Set-AzContext -SubscriptionId $Config.SubscriptionId
            Write-Log "Switched to subscription: $($Config.SubscriptionId)"
        }
    }
    catch {
        throw "Failed to authenticate to Azure: $($_.Exception.Message)"
    }
}

# Function to deploy using Terraform
function Deploy-WithTerraform {
    param($Config)
    
    Write-Log "Starting Terraform deployment..."
    
    try {
        # Initialize Terraform
        Write-Log "Initializing Terraform..."
        terraform init
        
        if ($LASTEXITCODE -ne 0) {
            throw "Terraform init failed"
        }
        
        # Select or create workspace
        $workspaceName = $Environment.ToLower()
        Write-Log "Selecting Terraform workspace: $workspaceName"
        
        terraform workspace select $workspaceName 2>$null
        if ($LASTEXITCODE -ne 0) {
            Write-Log "Creating new workspace: $workspaceName"
            terraform workspace new $workspaceName
        }
        
        # Plan deployment
        Write-Log "Planning Terraform deployment..."
        $planFile = "tfplan-$(Get-Date -Format 'yyyyMMdd-HHmmss').out"
        
        $terraformVars = @(
            "-var", "environment=$Environment"
            "-var", "location=$Location"
            "-var", "organization_name=$($Config.OrganizationName)"
            "-var", "connectivity_subscription_id=$($Config.ConnectivitySubscriptionId)"
            "-var", "management_subscription_id=$($Config.ManagementSubscriptionId)"
            "-var", "identity_subscription_id=$($Config.IdentitySubscriptionId)"
        )
        
        terraform plan -out=$planFile @terraformVars
        
        if ($LASTEXITCODE -ne 0) {
            throw "Terraform plan failed"
        }
        
        if ($WhatIf) {
            Write-Log "WhatIf specified - skipping actual deployment"
            return
        }
        
        # Apply deployment
        Write-Log "Applying Terraform deployment..."
        terraform apply -auto-approve $planFile
        
        if ($LASTEXITCODE -ne 0) {
            throw "Terraform apply failed"
        }
        
        Write-Log "Terraform deployment completed successfully"
    }
    catch {
        Write-Log "Terraform deployment failed: $($_.Exception.Message)" -Level ERROR
        throw
    }
}

# Function to deploy using ARM templates
function Deploy-WithARM {
    param($Config)
    
    Write-Log "Starting ARM template deployment..."
    
    try {
        $templateFile = "azuredeploy.json"
        $parametersFile = "azuredeploy.parameters.json"
        
        # Create parameters object
        $parameters = @{
            organizationName = $Config.OrganizationName
            environment = $Environment
            location = $Location
            enableAzureFirewall = $Config.EnableAzureFirewall
            enableVpnGateway = $Config.EnableVpnGateway
            enableBastion = $Config.EnableBastion
        }
        
        # Create resource group if it doesn't exist
        $resourceGroupName = "rg-enterprise-landing-zone-$($Environment.ToLower())"
        
        $rg = Get-AzResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue
        if (!$rg) {
            Write-Log "Creating resource group: $resourceGroupName"
            New-AzResourceGroup -Name $resourceGroupName -Location $Location
        }
        
        if ($WhatIf) {
            Write-Log "WhatIf specified - validating template..."
            Test-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $templateFile -TemplateParameterObject $parameters
            return
        }
        
        # Deploy ARM template
        Write-Log "Deploying ARM template..."
        $deployment = New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $templateFile -TemplateParameterObject $parameters -Verbose
        
        if ($deployment.ProvisioningState -eq "Succeeded") {
            Write-Log "ARM template deployment completed successfully"
        } else {
            throw "ARM template deployment failed with status: $($deployment.ProvisioningState)"
        }
    }
    catch {
        Write-Log "ARM deployment failed: $($_.Exception.Message)" -Level ERROR
        throw
    }
}

# Function to deploy using Bicep
function Deploy-WithBicep {
    param($Config)
    
    Write-Log "Starting Bicep deployment..."
    
    try {
        $bicepFile = "main.bicep"
        
        # Create parameters object
        $parameters = @{
            organizationName = $Config.OrganizationName
            environment = $Environment
            location = $Location
            enableAzureFirewall = $Config.EnableAzureFirewall
            enableVpnGateway = $Config.EnableVpnGateway
            enableBastion = $Config.EnableBastion
        }
        
        # Create resource group
        $resourceGroupName = "rg-enterprise-landing-zone-$($Environment.ToLower())"
        
        $rg = Get-AzResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue
        if (!$rg) {
            Write-Log "Creating resource group: $resourceGroupName"
            New-AzResourceGroup -Name $resourceGroupName -Location $Location
        }
        
        if ($WhatIf) {
            Write-Log "WhatIf specified - validating Bicep template..."
            Test-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $bicepFile -TemplateParameterObject $parameters
            return
        }
        
        # Deploy Bicep template
        Write-Log "Deploying Bicep template..."
        $deployment = New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $bicepFile -TemplateParameterObject $parameters -Verbose
        
        if ($deployment.ProvisioningState -eq "Succeeded") {
            Write-Log "Bicep deployment completed successfully"
        } else {
            throw "Bicep deployment failed with status: $($deployment.ProvisioningState)"
        }
    }
    catch {
        Write-Log "Bicep deployment failed: $($_.Exception.Message)" -Level ERROR
        throw
    }
}

# Main execution
try {
    Write-Log "Starting Azure Enterprise Landing Zone deployment"
    Write-Log "Deployment Method: $DeploymentMethod"
    Write-Log "Environment: $Environment"
    Write-Log "Location: $Location"
    
    # Validate prerequisites
    Test-Prerequisites
    
    # Load configuration
    $config = Get-Configuration -ConfigPath $ConfigFile
    
    # Connect to Azure
    Connect-AzureAccount -Config $config
    
    # Deploy based on method
    switch ($DeploymentMethod) {
        "Terraform" { Deploy-WithTerraform -Config $config }
        "ARM" { Deploy-WithARM -Config $config }
        "Bicep" { Deploy-WithBicep -Config $config }
    }
    
    Write-Log "Azure Enterprise Landing Zone deployment completed successfully"
}
catch {
    Write-Log "Deployment failed: $($_.Exception.Message)" -Level ERROR
    exit 1
}
```

This comprehensive configuration templates document provides all the necessary Infrastructure as Code templates for deploying the Azure Enterprise Landing Zone solution using multiple deployment methods and tools.