resource "azurerm_app_service_plan" "plan" {
  name                = var.azurerm_app_service_plan_name
  resource_group_name = var.resource_group_name
  location            = var.location
  reserved            = true
  kind                = "Linux"

  sku {
    tier = "ElasticPremium"
    size = "EP1"
  }

  lifecycle {
    ignore_changes = [
      kind
    ]
  }
}

resource "azurerm_function_app" "func" {
  name                       = var.azurerm_function_app_name
  resource_group_name        = var.resource_group_name
  location                   = var.location
  app_service_plan_id        = azurerm_app_service_plan.plan.id
  storage_account_name       = var.azurerm_function_app_storage_account_name
  storage_account_access_key = var.azurerm_function_app_storage_account_access_key
  version                    = "~3"
  enable_builtin_logging     = false
  os_type                    = "linux"
  app_settings               = merge(local.app_settings, var.azurerm_function_app_app_settings)

  site_config {
    pre_warmed_instance_count        = 1
    linux_fx_version                 = var.linux_fx_version
    runtime_scale_monitoring_enabled = true
    vnet_route_all_enabled           = true
    ftps_state                       = "Disabled"
  }

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [
      app_settings
    ]
  }
}

resource "azurerm_app_service_virtual_network_swift_connection" "fn_vnet_swift" {
  app_service_id = azurerm_function_app.func.id
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
    private_connection_resource_id = azurerm_function_app.func.id
    subresource_names              = ["sites"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "sites-private-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.sites_private_link.id]
  }
}


locals {
  # terraform auto provisions AzureWebJobsStorage and WEBSITE_CONTENTAZUREFILECONNECTIONSTRING, which cannot be overridden
  app_settings = {
    FUNCTIONS_WORKER_RUNTIME       = var.functions_worker_runtime
    APPINSIGHTS_INSTRUMENTATIONKEY = var.azurerm_function_app_appinsights_instrumentation_key
  }
}
