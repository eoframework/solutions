#------------------------------------------------------------------------------
# Disaster Recovery Module
# Creates: DR App Service in secondary region
#------------------------------------------------------------------------------

terraform {
  required_providers {
    azurerm = {
      source                = "hashicorp/azurerm"
      version               = "~> 3.80"
      configuration_aliases = [azurerm.dr]
    }
  }
}

#------------------------------------------------------------------------------
# DR Resource Group
#------------------------------------------------------------------------------
resource "azurerm_resource_group" "dr" {
  provider = azurerm.dr
  name     = "${var.name_prefix}-dr-rg"
  location = var.dr_location
  tags     = var.common_tags
}

#------------------------------------------------------------------------------
# DR App Service Plan
#------------------------------------------------------------------------------
resource "azurerm_service_plan" "dr" {
  provider            = azurerm.dr
  name                = "${var.name_prefix}-dr-asp"
  location            = azurerm_resource_group.dr.location
  resource_group_name = azurerm_resource_group.dr.name
  os_type             = "Linux"
  sku_name            = "P1v3"

  tags = var.common_tags
}

#------------------------------------------------------------------------------
# DR App Service
#------------------------------------------------------------------------------
resource "azurerm_linux_web_app" "dr" {
  provider            = azurerm.dr
  name                = "${var.name_prefix}-dr-app"
  location            = azurerm_resource_group.dr.location
  resource_group_name = azurerm_resource_group.dr.name
  service_plan_id     = azurerm_service_plan.dr.id

  identity {
    type = "SystemAssigned"
  }

  site_config {
    always_on = true
    health_check_path = "/health"
  }

  tags = var.common_tags
}
