# Create the primary storage account.
resource "azurerm_storage_account" "st" {
  name                     = var.azurerm_storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.azurerm_storage_account_account_tier
  account_kind             = var.azurerm_storage_account_account_kind
  account_replication_type = var.azurerm_storage_account_replication_type
}

resource "azurerm_storage_share" "st_share" {
  name                 = var.azurerm_storage_share_name
  storage_account_name = azurerm_storage_account.st.name
  quota                = 5120
}

resource "azurerm_private_dns_zone" "blob_privatelink" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "blob_privatelink" {
  name                  = "blob_privatelink"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.blob_privatelink.name
  virtual_network_id    = var.azurerm_private_dns_zone_virtual_network_id
}

resource "azurerm_private_endpoint" "storage_blob" {
  name                = var.azurerm_private_endpoint_storage_blob_name
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = var.azurerm_private_endpoint_storage_endpoint_subnet_id

  private_service_connection {
    name                           = var.azurerm_private_endpoint_storage_blob_service_connection_name
    private_connection_resource_id = azurerm_storage_account.st.id
    is_manual_connection           = false
    subresource_names = [
      "blob"
    ]
  }

  private_dns_zone_group {
    name                 = "storage-blob-private-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.blob_privatelink.id]
  }
}

resource "azurerm_private_dns_zone" "queue_privatelink" {
  name                = "privatelink.queue.core.windows.net"
  resource_group_name = var.resource_group_name
}
resource "azurerm_private_dns_zone_virtual_network_link" "queue_privatelink" {
  name                  = "queue_privatelink"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.queue_privatelink.name
  virtual_network_id    = var.azurerm_private_dns_zone_virtual_network_id
}
resource "azurerm_private_endpoint" "storage_queue" {
  name                = var.azurerm_private_endpoint_storage_queue_name
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = var.azurerm_private_endpoint_storage_endpoint_subnet_id

  private_service_connection {
    name                           = var.azurerm_private_endpoint_storage_queue_service_connection_name
    private_connection_resource_id = azurerm_storage_account.st.id
    is_manual_connection           = false
    subresource_names = [
      "queue"
    ]
  }

  private_dns_zone_group {
    name                 = "storage-blob-private-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.queue_privatelink.id]
  }
}

resource "azurerm_private_dns_zone" "file_privatelink" {
  name                = "privatelink.file.core.windows.net"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "file_privatelink" {
  name                  = "file_privatelink"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.file_privatelink.name
  virtual_network_id    = var.azurerm_private_dns_zone_virtual_network_id
}

resource "azurerm_private_endpoint" "storage_file" {
  name                = var.azurerm_private_endpoint_storage_file_name
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = var.azurerm_private_endpoint_storage_endpoint_subnet_id

  private_service_connection {
    name                           = var.azurerm_private_endpoint_storage_file_service_connection_name
    private_connection_resource_id = azurerm_storage_account.st.id
    is_manual_connection           = false
    subresource_names = [
      "file"
    ]
  }

  private_dns_zone_group {
    name                 = "storage-file-private-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.file_privatelink.id]
  }
}

resource "azurerm_private_dns_zone" "table_privatelink" {
  name                = "privatelink.table.core.windows.net"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "table_privatelink" {
  name                  = "table_privatelink"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.table_privatelink.name
  virtual_network_id    = var.azurerm_private_dns_zone_virtual_network_id
}

resource "azurerm_private_endpoint" "storage_table" {
  name                = var.azurerm_private_endpoint_storage_table_name
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = var.azurerm_private_endpoint_storage_endpoint_subnet_id

  private_service_connection {
    name                           = var.azurerm_private_endpoint_storage_table_service_connection_name
    private_connection_resource_id = azurerm_storage_account.st.id
    is_manual_connection           = false
    subresource_names = [
      "table"
    ]
  }

  private_dns_zone_group {
    name                 = "storage-table-private-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.table_privatelink.id]
  }
}
