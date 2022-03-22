resource "azurerm_log_analytics_workspace" "log_analytics_workspace" {
  name                = var.azurerm_log_analytics_workspace_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "PerGB2018"
}

resource "azurerm_application_insights" "appi" {
  name                = var.azurerm_application_insights_name
  resource_group_name = var.resource_group_name
  location            = var.location
  workspace_id        = azurerm_log_analytics_workspace.log_analytics_workspace.id
  application_type    = "web"
}
