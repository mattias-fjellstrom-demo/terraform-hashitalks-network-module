variables {
  name_suffix = "test"
  location    = "swedencentral"
}

run "setup" {
  module {
    source  = "app.terraform.io/mattias-fjellstrom/resource-group-module/hashitalks"
    version = "2.0.1"
  }

  assert {
    condition     = length(azurerm_resource_group.this.name) < 30
    error_message = "Resource group name too short"
  }
}

run "network" {
  variables {
    vnet_cidr = "10.0.0.0/8"
    resource_group = run.setup.resource_group
  }

  assert {
    condition     = length(azurerm_subnet.this[*].id) >= 3
    error_message = "Too few subnets are created, should be three or more"
  }
}