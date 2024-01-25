// -----------------------------------------------------------------------------
// CONFIGURE PROVIDERS
// -----------------------------------------------------------------------------
provider "azurerm" {
  features {}
}

// -----------------------------------------------------------------------------
// CONFIGURE VARIABLES
// -----------------------------------------------------------------------------
variables {
  name_suffix     = "hashitalks"
  vnet_cidr_range = "10.0.0.0/8"
  subnets = [
    {
      name              = "subnet-1"
      subnet_cidr_range = "10.0.10.0/24"
    }
  ]
}

// -----------------------------------------------------------------------------
// SET UP DEPENDENCIES
// -----------------------------------------------------------------------------
run "setup_resource_group" {
  variables {
    resource_group_name     = "rg-hashitalks"
    resource_group_location = "swedencentral"
  }

  module {
    source = "./testing/resource-group"
  }
}

// -----------------------------------------------------------------------------
// TESTS
// -----------------------------------------------------------------------------
run "should_not_allow_vnet_name_prefix" {
  command = plan

  variables {
    name_suffix    = "vnet-test"
    resource_group = run.setup_resource_group.resource_group
  }

  expect_failures = [
    var.name_suffix,
  ]
}

run "should_enforce_name_suffix_length_constraint" {
  command = plan

  variables {
    name_suffix    = replace("**********", "*", "abcdefghij")
    resource_group = run.setup_resource_group.resource_group
  }

  expect_failures = [
    var.name_suffix,
  ]
}

run "should_not_allow_non_rfc_1918_cidr_space" {
  command = plan

  variables {
    resource_group  = run.setup_resource_group.resource_group
    vnet_cidr_range = "33.33.0.0/16"
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

run "subnet_names_should_have_prefix" {
  command = plan

  variables {
    resource_group = run.setup_resource_group.resource_group
    subnets = [
      {
        name              = "subnet-1"
        subnet_cidr_range = "10.0.10.0/24"
      },
      {
        name              = "subnet-2"
        subnet_cidr_range = "10.0.20.0/24"
      }
    ]
  }

  assert {
    condition     = alltrue([for k, v in azurerm_subnet.this : startswith(azurerm_subnet.this[k].name, "snet-")])
    error_message = "Subnet name prefix is not set correctly"
  }
}

run "should_plan_correct_number_of_subnets" {
  command = plan

  variables {
    resource_group = run.setup_resource_group.resource_group
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
    error_message = "Incorrect number of subnets in plan"
  }
}

run "should_output_correct_number_of_subnets" {
  command = apply

  variables {
    resource_group = run.setup_resource_group.resource_group
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
    condition     = length(output.subnets) == 3
    error_message = "Incorrect number of subnets in output"
  }
}
