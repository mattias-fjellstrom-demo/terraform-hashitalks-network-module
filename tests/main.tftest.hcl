provider "azurerm" {
  features {}
}

variables {
  name_suffix     = "test"
  location        = "swedencentral"
  vnet_cidr_range = "10.0.0.0/8"
  subnets = [
    {
      name              = "subnet-1"
      subnet_cidr_range = "10.0.10.0/24"
    }
  ]
}

run "setup" {
  module {
    source  = "app.terraform.io/mattias-fjellstrom/resource-group-module/hashitalks"
    version = "1.0.0"
  }
}

run "should_not_allow_vnet_name_prefix" {
  command = plan

  variables {
    name_suffix    = "vnet-test"
    resource_group = run.setup.resource_group
  }

  expect_failures = [
    var.name_suffix,
  ]
}

run "should_not_allow_too_long_name" {
  command = plan

  variables {
    name_suffix    = replace("**********", "*", "abcdefghij")
    resource_group = run.setup.resource_group
  }

  expect_failures = [
    var.name_suffix,
  ]
}

run "should_not_allow_non_rfc_1918_cidr_space" {
  command = plan

  variables {
    vnet_cidr_range = "33.33.0.0/16"
    resource_group  = run.setup.resource_group
    subnets = [
      {
        name              = "subnet-1"
        subnet_cidr_range = "33.33.10.0/24"
      }
    ]
  }

  expect_failures = [
    var.vnet_cidr_range,
  ]
}

run "should_create_correct_number_of_subnets" {
  command = plan

  variables {
    resource_group = run.setup.resource_group

    subnets = [
      {
        name              = "subnet-1"
        subnet_cidr_range = "10.0.10.0/24"
      },
      {
        name              = "subnet-2"
        subnet_cidr_range = "10.0.20.0/24"
      },
      {
        name              = "subnet-3"
        subnet_cidr_range = "10.0.30.0/24"
      }
    ]
  }

  assert {
    condition     = length(azurerm_subnet.this) == 3
    error_message = "Incorrect number of subnets were created"
  }
}
