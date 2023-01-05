resource "azurerm_service_plan" "plan" {
  name                = var.azurerm_app_service_plan_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku_name            = "EP1"
  os_type             = "Linux"
}

resource "azurerm_linux_function_app" "func" {
  name                = var.azurerm_function_app_name
  resource_group_name = var.resource_group_name
  location            = var.location

  service_plan_id                 = azurerm_service_plan.plan.id
  storage_key_vault_secret_id     = var.azurerm_function_app_storage_key_vault_id
  key_vault_reference_identity_id = var.azurerm_function_app_identity_id
  functions_extension_version     = "~4"
  builtin_logging_enabled         = false

  identity {
    type         = "UserAssigned"
    identity_ids = [var.azurerm_function_app_identity_id]
  }

  site_config {
    runtime_scale_monitoring_enabled = true
    vnet_route_all_enabled           = true
    ftps_state                       = "Disabled"

    application_insights_connection_string = var.azurerm_function_app_application_insights_connection_string

    application_stack {
      dotnet_version = "6.0"
    }
  }

  app_settings = {
    WEBSITE_CONTENTOVERVNET              = 1
    WEBSITE_CONTENTSHARE                 = var.azurerm_function_app_website_content_share
    WEBSITE_SKIP_CONTENTSHARE_VALIDATION = 1
  }
}

resource "azurerm_app_service_virtual_network_swift_connection" "fn_vnet_swift" {
  app_service_id = azurerm_linux_function_app.func.id
  subnet_id      = var.azurerm_app_service_virtual_network_swift_connection_subnet_id
}

resource "azurerm_private_dns_zone" "sites_private_link" {
  name                = "privatelink.azurewebsites.net"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "sites_private_link" {
  name                  = "azurewebsites_privatelink"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.sites_private_link.name
  virtual_network_id    = var.azurerm_private_dns_zone_virtual_network_id
}

resource "azurerm_private_endpoint" "sites_private_endpoint" {
  name                = var.azurerm_private_endpoint_sites_name
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = var.azurerm_private_endpoint_sites_private_endpoint_subnet_id

  private_service_connection {
    name                           = "azurewebsites-private-service-connection"
    private_connection_resource_id = azurerm_linux_function_app.func.id
    subresource_names              = ["sites"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "sites-private-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.sites_private_link.id]
  }
}
