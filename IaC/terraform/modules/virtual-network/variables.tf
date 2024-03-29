variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the Azure resources."
}

variable "location" {
  type        = string
  description = "The Azure region for the specified resources."
}

variable "azurerm_virtual_network_name" {
  type        = string
  description = "The name of the Azure virtual network."
}

variable "azurerm_network_security_group_name" {
  type        = string
  description = "The name of the network security group."
}

variable "azurerm_virtual_network_address_space" {
  type        = string
  description = "The address space that is used the virtual network."
}

variable "azurerm_subnet_bastion_address_prefixes" {
  type        = string
  description = "The virtual network address prefix to use for the Azure Bastion subnet."
}

variable "azurerm_subnet_app_service_integration_address_prefixes" {
  type        = string
  description = "The virtual network address prefix to use for App Service virtual network integration."
}

variable "azurerm_subnet_vm_address_prefixes" {
  type        = string
  description = "The virtual network address prefix to use for the virtual machine."
}

variable "azurerm_subnet_private_endpoints_address_prefixes" {
  type        = string
  description = "The virtual network address prefix to use for private endpoints."
}

variable "azurerm_subnet_vm_subnet_name" {
  type        = string
  description = "The name of the virtual network subnet used for the virtual machine."
}

variable "azurerm_subnet_app_service_integration_subnet_name" {
  type        = string
  description = "The name of the virtual network subnet used for App Service virtual network integration."
}

variable "azurerm_subnet_private_endpoints_name" {
  type        = string
  description = "The name of the virtual network subnet used for private endpoints."
}

variable "azurerm_subnet_app_service_integration_service_endpoints" {
  type = list(string)
}
