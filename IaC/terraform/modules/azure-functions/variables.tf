variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the Azure resources."
}

variable "location" {
  type        = string
  description = "The Azure region for the specified resources."
}

variable "azurerm_app_service_plan_name" {
  type        = string
  description = "The name of the App Service plan."
}

variable "azurerm_function_app_name" {
  type        = string
  description = "The name of the function app."
}

variable "azurerm_function_app_storage_key_vault_id" {
  type        = string
  description = "Id for the Key Vault secret containing the Azure Storage connection string to be used by the Azure Function."
}

variable "azurerm_function_app_identity_id" {
  type        = string
  description = "Id for the managed identity used by the Azure Function."
}

variable "azurerm_function_app_application_insights_connection_string" {
  type        = string
  description = "The Application Insights connection string used by the function app."
  sensitive   = true
}

variable "azurerm_function_app_website_content_share" {
  type        = string
  description = "The name of the Azure Storage file share used by the function app."
}

variable "azurerm_app_service_virtual_network_swift_connection_subnet_id" {
  type        = string
  description = "The ID for the virtual network subnet used for virtual network integration."
}

variable "azurerm_private_endpoint_sites_private_endpoint_subnet_id" {
  type        = string
  description = "The ID of the virtual network subnet from which private IP addresses will be allocated for the private endpoint."
}

variable "azurerm_private_dns_zone_virtual_network_id" {
  type        = string
  description = "The ID of the virtual network that should be linked to the DNS Zone."
}

variable "azurerm_private_endpoint_sites_name" {
  type        = string
  description = "The name for the Azure Function's private endpoint."
}
