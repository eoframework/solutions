#------------------------------------------------------------------------------
# Virtual WAN Core Infrastructure Module
# Creates: Resource Group, Virtual WAN, Virtual Hubs (Primary & Secondary)
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Resource Group
#------------------------------------------------------------------------------
resource "azurerm_resource_group" "main" {
  name     = "${var.name_prefix}-rg"
  location = var.location
  tags     = var.common_tags
}

#------------------------------------------------------------------------------
# Virtual WAN
#------------------------------------------------------------------------------
module "virtual_wan" {
  source = "../../azure/virtual-wan"

  name                = "${var.name_prefix}-vwan"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location

  wan_type                          = var.wan_type
  allow_branch_to_branch_traffic    = var.allow_branch_to_branch_traffic
  office365_local_breakout_category = var.office365_local_breakout_category

  tags = var.common_tags
}

#------------------------------------------------------------------------------
# Primary Virtual Hub
#------------------------------------------------------------------------------
module "primary_hub" {
  source = "../../azure/virtual-hub"

  name                = "${var.name_prefix}-hub-primary"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  virtual_wan_id      = module.virtual_wan.id
  address_prefix      = var.primary_hub_address_prefix
  sku                 = var.hub_sku
  hub_routing_preference = var.hub_routing_preference

  create_route_table = var.create_custom_route_tables
  route_table_labels = var.primary_hub_route_table_labels
  routes             = var.primary_hub_routes

  tags = var.common_tags
}

#------------------------------------------------------------------------------
# Secondary Virtual Hub
#------------------------------------------------------------------------------
module "secondary_hub" {
  count  = var.enable_secondary_hub ? 1 : 0
  source = "../../azure/virtual-hub"

  name                = "${var.name_prefix}-hub-secondary"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.secondary_location
  virtual_wan_id      = module.virtual_wan.id
  address_prefix      = var.secondary_hub_address_prefix
  sku                 = var.hub_sku
  hub_routing_preference = var.hub_routing_preference

  create_route_table = var.create_custom_route_tables
  route_table_labels = var.secondary_hub_route_table_labels
  routes             = var.secondary_hub_routes

  tags = var.common_tags
}
