
output "subnet_data" {
  description = "a map of Subnet Name to Resource ID"
  value       = zipmap(azurerm_subnet.subnet[*].name, azurerm_subnet.subnet[*].id)
}

output "subnet_id" {
  description = "The Resource Id of the subnet created"
  value       = azurerm_subnet.subnet.id
}

