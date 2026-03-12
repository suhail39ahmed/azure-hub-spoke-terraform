variable "prefix" {
  type = string
}

variable "spoke_name" {
  description = "Short name for this spoke (e.g. prod, dev, shared)"
  type        = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "address_space" {
  description = "CIDR for spoke VNet"
  type        = string
}

variable "subnets" {
  description = "List of { name, cidr } for subnets"
  type = list(object({
    name = string
    cidr = string
  }))
}

variable "hub_firewall_private_ip" {
  description = "Hub Azure Firewall private IP for default route"
  type        = string
}

variable "tags" {
  type        = map(string)
  default     = {}
}
