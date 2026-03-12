variable "prefix" {
  description = "Naming prefix for resources"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the hub resource group"
  type        = string
}

variable "hub_address_space" {
  description = "CIDR for hub VNet (e.g. 10.0.0.0/16)"
  type        = string
  default     = "10.0.0.0/16"
}

variable "firewall_subnet_cidr" {
  description = "CIDR for Azure Firewall subnet (/26)"
  type        = string
  default     = "10.0.1.0/26"
}

variable "gateway_subnet_cidr" {
  description = "CIDR for VPN/ER Gateway subnet"
  type        = string
  default     = "10.0.2.0/27"
}

variable "bastion_subnet_cidr" {
  description = "CIDR for Azure Bastion subnet (/26)"
  type        = string
  default     = "10.0.3.0/26"
}

variable "tags" {
  description = "Tags applied to all resources"
  type        = map(string)
  default     = {}
}
