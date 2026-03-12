# Example: Hub + 3 spokes (prod, dev, shared) with peering
terraform {
  required_providers {
    azurerm = { source = "hashicorp/azurerm" }
  }
  backend "azurerm" {}
}

locals {
  prefix = "contoso"
  location = "eastus"
  tags = {
    Environment = "demo"
    ManagedBy   = "terraform"
  }
}

module "hub" {
  source = "../../modules/hub"

  prefix              = local.prefix
  location            = local.location
  resource_group_name = "${local.prefix}-hub-rg"
  hub_address_space   = "10.0.0.0/16"
  tags                = local.tags
}

module "spoke_prod" {
  source = "../../modules/spoke"

  prefix                   = local.prefix
  spoke_name               = "prod"
  location                 = local.location
  resource_group_name      = "${local.prefix}-spoke-prod-rg"
  address_space            = "10.1.0.0/16"
  hub_firewall_private_ip   = module.hub.firewall_private_ip
  subnets = [
    { name = "app", cidr = "10.1.1.0/24" },
    { name = "data", cidr = "10.1.2.0/24" }
  ]
  tags = local.tags
}

module "spoke_dev" {
  source = "../../modules/spoke"

  prefix                   = local.prefix
  spoke_name               = "dev"
  location                 = local.location
  resource_group_name      = "${local.prefix}-spoke-dev-rg"
  address_space            = "10.2.0.0/16"
  hub_firewall_private_ip   = module.hub.firewall_private_ip
  subnets = [
    { name = "app", cidr = "10.2.1.0/24" }
  ]
  tags = local.tags
}

module "spoke_shared" {
  source = "../../modules/spoke"

  prefix                   = local.prefix
  spoke_name               = "shared"
  location                 = local.location
  resource_group_name      = "${local.prefix}-spoke-shared-rg"
  address_space            = "10.3.0.0/16"
  hub_firewall_private_ip   = module.hub.firewall_private_ip
  subnets = [
    { name = "acr", cidr = "10.3.1.0/24" },
    { name = "kv", cidr = "10.3.2.0/24" }
  ]
  tags = local.tags
}

# VNet peering: hub <-> spokes (bidirectional)
resource "azurerm_virtual_network_peering" "hub_to_prod" {
  name                         = "hub-to-spoke-prod"
  resource_group_name          = module.hub.resource_group_name
  virtual_network_name         = module.hub.vnet_name
  remote_virtual_network_id     = module.spoke_prod.vnet_id
  allow_forwarded_traffic      = true
  allow_gateway_transit         = false
  use_remote_gateways          = false
}

resource "azurerm_virtual_network_peering" "prod_to_hub" {
  name                         = "spoke-prod-to-hub"
  resource_group_name          = module.spoke_prod.resource_group_name
  virtual_network_name         = module.spoke_prod.vnet_name
  remote_virtual_network_id     = module.hub.vnet_id
  allow_forwarded_traffic       = false
  allow_gateway_transit         = true
  use_remote_gateways           = false
}

resource "azurerm_virtual_network_peering" "hub_to_dev" {
  name                         = "hub-to-spoke-dev"
  resource_group_name          = module.hub.resource_group_name
  virtual_network_name         = module.hub.vnet_name
  remote_virtual_network_id    = module.spoke_dev.vnet_id
  allow_forwarded_traffic       = true
}

resource "azurerm_virtual_network_peering" "dev_to_hub" {
  name                         = "spoke-dev-to-hub"
  resource_group_name          = module.spoke_dev.resource_group_name
  virtual_network_name         = module.spoke_dev.vnet_name
  remote_virtual_network_id    = module.hub.vnet_id
  allow_gateway_transit        = true
}

resource "azurerm_virtual_network_peering" "hub_to_shared" {
  name                         = "hub-to-spoke-shared"
  resource_group_name          = module.hub.resource_group_name
  virtual_network_name         = module.hub.vnet_name
  remote_virtual_network_id    = module.spoke_shared.vnet_id
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "shared_to_hub" {
  name                         = "spoke-shared-to-hub"
  resource_group_name          = module.spoke_shared.resource_group_name
  virtual_network_name         = module.spoke_shared.vnet_name
  remote_virtual_network_id    = module.hub.vnet_id
  allow_gateway_transit        = true
}
