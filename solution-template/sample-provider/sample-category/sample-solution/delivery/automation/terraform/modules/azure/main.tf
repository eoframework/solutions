# Azure Provider-Specific Module
# This module contains all Azure-specific resources and configurations

# Local values for Azure resource naming
locals {
  azure_name_prefix = "${var.name_prefix}-azure"

  # Common tags for all Azure resources
  azure_tags = merge(var.tags, {
    Provider = "Azure"
    Location = var.location
  })
}

# Azure Networking Module
module "networking" {
  source = "./networking"

  name_prefix = local.azure_name_prefix
  tags        = local.azure_tags
}

# Azure Security Module
module "security" {
  source = "./security"

  name_prefix = local.azure_name_prefix
  tags        = local.azure_tags
}

# Azure Compute Module
module "compute" {
  source = "./compute"

  name_prefix = local.azure_name_prefix
  tags        = local.azure_tags
}

# Azure Monitoring Module
module "monitoring" {
  source = "./monitoring"

  project_name        = var.project_name
  environment         = var.environment
  name_prefix         = local.azure_name_prefix
  location            = var.location
  subscription_id     = var.subscription_id
  tags                = local.azure_tags
  log_retention_days  = var.log_retention_days
}

# Example Azure-specific resources
resource "azurerm_resource_group" "main" {
  name     = "${local.azure_name_prefix}-rg"
  location = var.location

  tags = merge(local.azure_tags, {
    Name = "${local.azure_name_prefix}-resource-group"
  })
}

resource "azurerm_storage_account" "app_storage" {
  name                     = "${replace(local.azure_name_prefix, "-", "")}app${random_id.storage_suffix.hex}"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = local.azure_tags
}

resource "random_id" "storage_suffix" {
  byte_length = 4
}