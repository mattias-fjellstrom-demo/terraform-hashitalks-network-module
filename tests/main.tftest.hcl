variables {
  name_suffix = "test"
  location    = "swedencentral"
}

run "setup" {
  module {
    source  = "app.terraform.io/mattias-fjellstrom/resource-group-module/hashitalks"
    version = "2.0.1"
  }
}

run "network" {
  variables {
    vnet_cidr_range = "10.0.0.0/8"
    resource_group  = run.setup.resource_group
    
    subnets = [
      {
        name              = "subnet-1"
        subnet_cidr_range = "10.0.10.0/24"
      }
      {
        name              = "subnet-2"
        subnet_cidr_range = "10.0.20.0/24"
      }
    ]
  }

  assert {
    condition     = length(azurerm_subnet.this[*]) == 2
    error_message = "Incorrect number of subnets were created"
  }
}