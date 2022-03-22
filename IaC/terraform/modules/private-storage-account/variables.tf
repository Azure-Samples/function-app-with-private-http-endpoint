variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the Azure resources."
}

variable "location" {
  type        = string
  description = "The Azure region for the specified resources."
}

variable "azurerm_storage_account_name" {
  type        = string
  description = "The name of the storage account."
}

variable "azurerm_storage_account_account_tier" {
  type        = string
  default     = "Standard"
  description = "The tier to use for this storage account."
}

variable "azurerm_storage_account_account_kind" {
  type        = string
  default     = "StorageV2"
  description = "The kind to use for this storage account."
}

variable "azurerm_storage_account_replication_type" {
  type        = string
  default     = "LRS"
  description = "The type of replication to use for this storage account."
}

variable "azurerm_storage_share_name" {
  type        = string
  default     = "fileshare"
  description = "The name of the storage account file share."
}

variable "azurerm_private_endpoint_storage_endpoint_subnet_id" {
  type        = string
  description = "The ID of the virtual network subnet from which private IP addresses will be allocated for the private endpoint."
}

variable "azurerm_private_dns_zone_virtual_network_id" {
  type        = string
  description = "The ID of the virtual network that should be linked to the DNS Zone."
}

variable "azurerm_private_endpoint_storage_blob_name" {
  type        = string
  description = "The name for the Azure storage account's private endpoint for the blob resource."
}

variable "azurerm_private_endpoint_storage_table_name" {
  type        = string
  description = "The name for the Azure storage account's private endpoint for the table resource."
}

variable "azurerm_private_endpoint_storage_queue_name" {
  type        = string
  description = "The name for the Azure storage account's private endpoint for the queue resource."
}

variable "azurerm_private_endpoint_storage_file_name" {
  type        = string
  description = "The name for the Azure storage account's private endpoint for the file resource."
}

variable "azurerm_private_endpoint_storage_table_service_connection_name" {
  type        = string
  description = "The name for the private endpoint connection for the Azure storage table resource."
}

variable "azurerm_private_endpoint_storage_file_service_connection_name" {
  type        = string
  description = "The name for the private endpoint connection for the Azure storage file resource."
}

variable "azurerm_private_endpoint_storage_queue_service_connection_name" {
  type        = string
  description = "The name for the private endpoint connection for the Azure storage queue resource."
}

variable "azurerm_private_endpoint_storage_blob_service_connection_name" {
  type        = string
  description = "The name for the private endpoint connection for the Azure storage blob resource."
}
