# Spoke VNet - workload isolation with peering to hub
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

resource "azurerm_resource_group" "spoke" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "spoke" {
  name                = "${var.prefix}-spoke-${var.spoke_name}-vnet"
  location            = azurerm_resource_group.spoke.location
  resource_group_name = azurerm_resource_group.spoke.name
  address_space       = [var.address_space]
  tags                = var.tags
}

resource "azurerm_subnet" "workload" {
  count                = length(var.subnets)
  name                 = var.subnets[count.index].name
  resource_group_name  = azurerm_resource_group.spoke.name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = [var.subnets[count.index].cidr]
}

# Route table to send default traffic via hub firewall
resource "azurerm_route_table" "spoke" {
  name                = "${var.prefix}-spoke-${var.spoke_name}-rt"
  location            = azurerm_resource_group.spoke.location
  resource_group_name = azurerm_resource_group.spoke.name
  tags                = var.tags
}

resource "azurerm_route" "default_via_firewall" {
  name                   = "default-via-fw"
  resource_group_name    = azurerm_resource_group.spoke.name
  route_table_name       = azurerm_route_table.spoke.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.hub_firewall_private_ip
}

resource "azurerm_subnet_route_table_association" "workload" {
  count          = length(azurerm_subnet.workload)
  subnet_id      = azurerm_subnet.workload[count.index].id
  route_table_id = azurerm_route_table.spoke.id
}
