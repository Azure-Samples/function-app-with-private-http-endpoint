variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the Azure resources."
}

variable "location" {
  type        = string
  description = "The Azure region for the specified resources."
}

variable "azurerm_key_vault_name" {
  type        = string
  description = "The name of the key vault."
}

variable "azurerm_private_endpoint_kv_private_endpoint_name" {
  type        = string
  description = "The name of the key vault private endpoint."
}

variable "azurerm_private_endpoint_kv_private_endpoint_subnet_id" {
  type        = string
  description = "The ID of the virtual network subnet from which private IP addresses will be allocated for the private endpoint."
}

variable "azurerm_private_endpoint_kv_private_endpoint_service_connection_name" {
  type        = string
  description = "The name for the private endpoint connection for the key vault. "
}

variable "azurerm_private_dns_zone_virtual_network_id" {
  type        = string
  description = "The ID of the virtual network that should be linked to the DNS Zone."
}
