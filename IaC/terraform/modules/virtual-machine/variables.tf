variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the Azure resources."
}

variable "location" {
  type        = string
  description = "The Azure region for the specified resources."
}

variable "azurerm_windows_virtual_machine_admin_username" {
  type        = string
  description = "The username to use for the virtual machine."
  sensitive   = true
}

variable "azurerm_windows_virtual_machine_admin_password" {
  type        = string
  description = "The password to use for the virtual machine."
  sensitive   = true
}

variable "azurerm_windows_virtual_machine_name" {
  type        = string
  description = "The name of the Windows VM."
}

variable "azurerm_windows_virtual_machine_size" {
  type        = string
  default     = "Standard_A2_v2"
  description = "The size of the Windows VM."
}

variable "azurerm_network_interface_name" {
  type        = string
  description = "The name of the network interface card (NIC) for the Windows VM."
}

variable "azurerm_network_interface_subnet_id" {
  type        = string
  description = "The ID of the virutal network subnet where this NIC should be located in."
}
