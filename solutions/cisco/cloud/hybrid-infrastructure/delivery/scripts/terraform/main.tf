# Cisco Hybrid Cloud Infrastructure - Terraform Configuration
# Multi-cloud infrastructure deployment with Cisco integration

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    ciscoasa = {
      source  = "CiscoDevNet/ciscoasa"
      version = "~> 1.3"
    }
  }
}

# AWS Provider Configuration
provider "aws" {
  region = var.aws_region
}

# Azure Provider Configuration
provider "azurerm" {
  features {}
}

# Cisco ASA Provider
provider "ciscoasa" {
  username = var.cisco_username
  password = var.cisco_password
  host     = var.cisco_host
}

# AWS VPC for hybrid connectivity
resource "aws_vpc" "hybrid" {
  cidr_block           = var.aws_vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-aws-vpc"
  })
}

# AWS Subnets
resource "aws_subnet" "private" {
  count             = length(var.aws_availability_zones)
  vpc_id            = aws_vpc.hybrid.id
  cidr_block        = cidrsubnet(var.aws_vpc_cidr, 8, count.index + 1)
  availability_zone = var.aws_availability_zones[count.index]

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-private-${count.index + 1}"
  })
}

# Azure Resource Group
resource "azurerm_resource_group" "hybrid" {
  name     = "${var.project_name}-hybrid-rg"
  location = var.azure_location

  tags = var.common_tags
}

# Azure Virtual Network
resource "azurerm_virtual_network" "hybrid" {
  name                = "${var.project_name}-vnet"
  address_space       = [var.azure_vnet_cidr]
  location            = azurerm_resource_group.hybrid.location
  resource_group_name = azurerm_resource_group.hybrid.name

  tags = var.common_tags
}

# Azure Subnet
resource "azurerm_subnet" "hybrid" {
  name                 = "${var.project_name}-subnet"
  resource_group_name  = azurerm_resource_group.hybrid.name
  virtual_network_name = azurerm_virtual_network.hybrid.name
  address_prefixes     = [var.azure_subnet_cidr]
}

# VPN Gateway for hybrid connectivity
resource "aws_vpn_gateway" "hybrid" {
  vpc_id = aws_vpc.hybrid.id

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-vpn-gw"
  })
}

# Azure VPN Gateway
resource "azurerm_public_ip" "vpn" {
  name                = "${var.project_name}-vpn-ip"
  location            = azurerm_resource_group.hybrid.location
  resource_group_name = azurerm_resource_group.hybrid.name
  allocation_method   = "Dynamic"

  tags = var.common_tags
}

resource "azurerm_virtual_network_gateway" "hybrid" {
  name                = "${var.project_name}-vpn-gw"
  location            = azurerm_resource_group.hybrid.location
  resource_group_name = azurerm_resource_group.hybrid.name

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false
  sku          = "Basic"

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id         = azurerm_public_ip.vpn.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                    = azurerm_subnet.gateway.id
  }

  tags = var.common_tags
}

resource "azurerm_subnet" "gateway" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.hybrid.name
  virtual_network_name = azurerm_virtual_network.hybrid.name
  address_prefixes     = [var.azure_gateway_subnet_cidr]
}