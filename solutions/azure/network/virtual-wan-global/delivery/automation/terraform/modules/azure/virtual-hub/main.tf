#------------------------------------------------------------------------------
# Azure Virtual Hub Module
#------------------------------------------------------------------------------

resource "azurerm_virtual_hub" "main" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  virtual_wan_id      = var.virtual_wan_id
  address_prefix      = var.address_prefix
  sku                 = var.sku
  hub_routing_preference = var.hub_routing_preference

  tags = var.tags
}

# Optional: Virtual Hub Route Table
resource "azurerm_virtual_hub_route_table" "main" {
  count          = var.create_route_table ? 1 : 0
  name           = "${var.name}-rt"
  virtual_hub_id = azurerm_virtual_hub.main.id
  labels         = var.route_table_labels

  dynamic "route" {
    for_each = var.routes
    content {
      name              = route.value.name
      destinations_type = route.value.destinations_type
      destinations      = route.value.destinations
      next_hop          = route.value.next_hop
    }
  }
}
