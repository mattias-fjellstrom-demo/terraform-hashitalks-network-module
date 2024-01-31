resource "azurerm_virtual_network" "this" {
  name                = "vnet-${var.name_suffix}"
  resource_group_name = var.resource_group.name
  location            = var.resource_group.location
  address_space       = [var.vnet_cidr_range]
  tags                = var.resource_group.tags
}

locals {
  subnets = { for subnet in var.subnets : subnet.name => subnet }
}

resource "azurerm_subnet" "this" {
  for_each             = local.subnets
  name                 = "snet-${each.key}"
  virtual_network_name = azurerm_virtual_network.this.name
  resource_group_name  = var.resource_group.name
  address_prefixes     = [each.value.subnet_cidr_range]

  // sanity check address
  lifecycle {
    precondition {
      condition     = startswith(each.value.subnet_cidr_range, split(".", var.vnet_cidr_range)[0])
      error_message = "Invalid CIDR address range for subnet"
    }

    precondition {
      condition     = tonumber(split("/", var.vnet_cidr_range)[1]) <= tonumber(split("/", each.value.subnet_cidr_range)[1])
      error_message = "Subnet cannot be larger than the virtual network"
    }
  }
}
