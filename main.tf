resource "azurerm_virtual_network" "this" {
  name                = "vnet-${var.name_suffix}"
  resource_group_name = var.resource_group.name
  location            = var.resource_group.location

  address_space = [var.vnet_cidr_range]
  tags          = var.resource_group.tags
}

resource "azurerm_subnet" "this" {
  for_each = { for subnet in var.subnets : subnet.name => subnet }

  name                 = "snet-${each.key}"
  virtual_network_name = azurerm_virtual_network.this.name
  resource_group_name  = var.resource_group.name
  address_prefixes     = [each.value.subnet_cidr_range]
}
