variable "name_suffix" {
  type        = string
  description = "Name suffix for virtual network resource (i.e. vnet-<NAME SUFFIX>)"

  validation {
    condition     = !startswith(var.name_suffix, "vnet-")
    error_message = "Do not start the name with 'vnet-'"
  }

  validation {
    condition     = length("vnet-${var.name_suffix}") <= 64
    error_message = "Virtual network name must be at most 64 characters long"
  }
}

variable "resource_group" {
  type = object({
    name     = string,
    location = string,
    tags     = object(any)
  })
  description = "Azure resource group object"
}

variable "vnet_cidr_range" {
  type        = string
  description = "Virtual network CIDR range"
  default     = "10.0.0.0/16"

  validation {
    condition     = contains(["10.0.0.0", "172.16.0.0", "192.168.0.0"], cidrhost(var.vnet_cidr_range, 0))
    error_message = "Use an RFC 1918 address (prefix from 10/8, 172.16/12, 192.168/16)"
  }
}

variable "subnets" {
  type = list(object({
    name              = string
    subnet_cidr_range = string
  }))
}
