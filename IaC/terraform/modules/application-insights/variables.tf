variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the Azure resources."
}

variable "location" {
  type        = string
  description = "The Azure region for the specified resources."
}

variable "azurerm_application_insights_name" {
  type        = string
  description = "The name of the Application Insights resource."
}

variable "azurerm_log_analytics_workspace_name" {
  type        = string
  description = "The name of the Log Analytics Workspace resource."
}
