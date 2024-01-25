terraform {
  required_version = "~> 1.7.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.88.0"
    }
  }
}

provider "azurerm" {
  features {}
}

variable "resource_group_name" {
  type = string
}

variable "resource_group_location" {
  type = string
}

resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.resource_group_location
  tags = {
    purpose = "testing"
  }
}

output "resource_group" {
  value = azurerm_resource_group.this
}
