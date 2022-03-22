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
