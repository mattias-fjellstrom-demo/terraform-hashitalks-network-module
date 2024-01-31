output "virtual_network" {
  value       = azurerm_virtual_network.this
  description = "Virtual network resource"
}

output "subnets" {
  value = [
    for k, v in azurerm_subnet.this :
    {
      id   = azurerm_subnet.this[k].id
      name = azurerm_subnet.this[k].name
    }
  ]
  description = "List of subnet objects (id, name)"
}
