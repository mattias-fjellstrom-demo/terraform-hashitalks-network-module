output "virtual_network" {
  value       = azurerm_virtual_network.this
  description = "Virtual network resource"
}

output "subnets" {
  value       = azurerm_subnet.this[*]
  description = "Subnet resources"
}
