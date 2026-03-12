output "resource_group_name" {
  value = azurerm_resource_group.spoke.name
}

output "vnet_id" {
  value = azurerm_virtual_network.spoke.id
}

output "vnet_name" {
  value = azurerm_virtual_network.spoke.name
}

output "subnet_ids" {
  value = { for s in azurerm_subnet.workload : s.name => s.id }
}
