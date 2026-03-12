# Hub VNet - centralized connectivity and security
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

resource "azurerm_resource_group" "hub" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "hub" {
  name                = "${var.prefix}-hub-vnet"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  address_space       = [var.hub_address_space]
  tags               = var.tags
}

resource "azurerm_subnet" "firewall" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name  = azurerm_virtual_network.hub.name
  address_prefixes     = [var.firewall_subnet_cidr]
}

resource "azurerm_subnet" "gateway" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.gateway_subnet_cidr]
}

resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.bastion_subnet_cidr]
}

resource "azurerm_public_ip" "firewall" {
  name                = "${var.prefix}-fw-pip"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  allocation_method   = "Static"
  sku                = "Standard"
  tags               = var.tags
}

resource "azurerm_firewall" "hub" {
  name                = "${var.prefix}-hub-fw"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  sku_name            = "AZFW_Hub"
  sku_tier            = "Standard"

  ip_configuration {
    name                 = "config"
    subnet_id            = azurerm_subnet.firewall.id
    public_ip_address_id = azurerm_public_ip.firewall.id
  }

  tags = var.tags
}

# FQDN-based application rule for outbound allow-list
resource "azurerm_firewall_application_rule_collection" "egress" {
  name                = "allow-fqdn-egress"
  azure_firewall_name  = azurerm_firewall.hub.name
  resource_group_name  = azurerm_resource_group.hub.name
  priority            = 100
  action              = "Allow"

  rule {
    name = "allow-azure-services"
    source_addresses = ["*"]
    fqdn_tags        = ["AzureCloud"]
  }
  rule {
    name = "allow-ubuntu-ntp"
    source_addresses = ["*"]
    target_fqdns     = ["*.ubuntu.com", "ntp.ubuntu.com"]
    protocol {
      port = "123"
      type = "Udp"
    }
  }
}
