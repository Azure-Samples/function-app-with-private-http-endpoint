variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the Azure resources."
}

variable "location" {
  type        = string
  description = "The Azure region for the specified resources."
}

variable "azurerm_bastion_host_name" {
  type        = string
  description = "The name of the Bastion Host."
}

variable "azurerm_bastion_host_subnet_id" {
  type        = string
  description = "The ID of the virtual network subnet in which this Bastion Host has been created."
}

variable "azurerm_public_ip_name" {
  type        = string
  description = "The name of the public IP address."
}

