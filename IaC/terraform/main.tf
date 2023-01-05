# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 3.30.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.4.3"
    }
  }

  required_version = "1.3.4"
}

provider "azurerm" {
  features {}
}

provider "random" {}

locals {
  base_name = random_string.base_name.result
}

data "azurerm_client_config" "current" {}

resource "random_string" "base_name" {
  length  = 13
  special = false
  numeric = true
  upper   = false
  keepers = {
    resource_group = var.resource_group_name
  }
}
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_user_assigned_identity" "funcid" {
  name                = "id-${local.base_name}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

module "vnet" {
  source                                                   = "./modules/virtual-network/"
  resource_group_name                                      = azurerm_resource_group.rg.name
  location                                                 = var.location
  azurerm_virtual_network_name                             = "vnet-${local.base_name}"
  azurerm_virtual_network_address_space                    = "10.0.0.0/16"
  azurerm_subnet_bastion_address_prefixes                  = "10.0.1.0/24"
  azurerm_subnet_vm_address_prefixes                       = "10.0.2.0/24"
  azurerm_subnet_app_service_integration_address_prefixes  = "10.0.3.0/24"
  azurerm_subnet_private_endpoints_address_prefixes        = "10.0.4.0/24"
  azurerm_subnet_vm_subnet_name                            = "snet-${local.base_name}-vm"
  azurerm_subnet_app_service_integration_subnet_name       = "snet-${local.base_name}-appServiceInt"
  azurerm_subnet_private_endpoints_name                    = "snet-${local.base_name}-privateEndpoints"
  azurerm_subnet_app_service_integration_service_endpoints = []
  azurerm_network_security_group_name                      = "nsg-${local.base_name}"
}

module "bastion" {
  source                         = "./modules/azure-bastion/"
  resource_group_name            = azurerm_resource_group.rg.name
  location                       = var.location
  azurerm_bastion_host_name      = "bas-${local.base_name}"
  azurerm_bastion_host_subnet_id = module.vnet.network_details.bastion_subnet_id
  azurerm_public_ip_name         = "pip-${local.base_name}"
}

module "windows_vm" {
  source                                         = "./modules/virtual-machine/"
  resource_group_name                            = azurerm_resource_group.rg.name
  location                                       = var.location
  azurerm_windows_virtual_machine_name           = "vm${local.base_name}"
  azurerm_network_interface_subnet_id            = module.vnet.network_details.vm_subnet_id
  azurerm_network_interface_name                 = "nic-${local.base_name}"
  azurerm_windows_virtual_machine_admin_password = var.azurerm_windows_virtual_machine_admin_password
  azurerm_windows_virtual_machine_admin_username = var.azurerm_windows_virtual_machine_admin_username
}

module "app_insights" {
  source                               = "./modules/application-insights"
  resource_group_name                  = azurerm_resource_group.rg.name
  location                             = var.location
  azurerm_application_insights_name    = "appi-${local.base_name}"
  azurerm_log_analytics_workspace_name = "log-${local.base_name}"
}

module "private_storage_account" {
  source                                                         = "./modules/private-storage-account/"
  resource_group_name                                            = azurerm_resource_group.rg.name
  location                                                       = var.location
  azurerm_storage_account_name                                   = "st${local.base_name}"
  azurerm_private_dns_zone_virtual_network_id                    = module.vnet.network_details.vnet_id
  azurerm_private_endpoint_storage_blob_name                     = "pe-${local.base_name}-stb"
  azurerm_private_endpoint_storage_file_name                     = "pe-${local.base_name}-stf"
  azurerm_private_endpoint_storage_queue_name                    = "pe-${local.base_name}-stq"
  azurerm_private_endpoint_storage_table_name                    = "pe-${local.base_name}-stt"
  azurerm_private_endpoint_storage_endpoint_subnet_id            = module.vnet.network_details.private_endpoint_subnet_id
  azurerm_private_endpoint_storage_table_service_connection_name = "st-table-private-service-connection"
  azurerm_private_endpoint_storage_file_service_connection_name  = "st-file-private-service-connection"
  azurerm_private_endpoint_storage_queue_service_connection_name = "st-queue-private-service-connection"
  azurerm_private_endpoint_storage_blob_service_connection_name  = "st-blob-private-service-connection"
}

module "function_app" {
  source                                                         = "./modules/azure-functions"
  resource_group_name                                            = azurerm_resource_group.rg.name
  location                                                       = var.location
  azurerm_app_service_plan_name                                  = "plan-${local.base_name}"
  azurerm_app_service_virtual_network_swift_connection_subnet_id = module.vnet.network_details.app_service_integration_subnet_id
  azurerm_function_app_name                                      = "func-${local.base_name}"
  azurerm_function_app_application_insights_connection_string    = module.app_insights.azurerm_application_insights_connection_string
  azurerm_function_app_storage_key_vault_id                      = azurerm_key_vault_secret.storage-connection-string.id
  azurerm_function_app_identity_id                               = azurerm_user_assigned_identity.funcid.id
  azurerm_function_app_website_content_share                     = module.private_storage_account.storage_account_details.file_share_name
  azurerm_private_dns_zone_virtual_network_id                    = module.vnet.network_details.vnet_id
  azurerm_private_endpoint_sites_private_endpoint_subnet_id      = module.vnet.network_details.private_endpoint_subnet_id
  azurerm_private_endpoint_sites_name                            = "pe-${local.base_name}-sites"
}

module "private_key_vault" {
  source                                                               = "./modules/private-key-vault"
  resource_group_name                                                  = azurerm_resource_group.rg.name
  location                                                             = var.location
  azurerm_key_vault_name                                               = "kv-${local.base_name}"
  azurerm_private_endpoint_kv_private_endpoint_name                    = "pe-${local.base_name}-kv"
  azurerm_private_endpoint_kv_private_endpoint_subnet_id               = module.vnet.network_details.private_endpoint_subnet_id
  azurerm_private_endpoint_kv_private_endpoint_service_connection_name = "kv-private-service-connection"
  azurerm_private_dns_zone_virtual_network_id                          = module.vnet.network_details.vnet_id
}

resource "azurerm_storage_account_network_rules" "st_network_rules" {
  storage_account_id = module.private_storage_account.storage_account_details.id
  default_action     = "Deny"
  bypass             = ["None"]

  depends_on = [
    module.private_storage_account,
    module.function_app
  ]
}

resource "azurerm_key_vault_access_policy" "kv_func_access_policy" {
  key_vault_id = module.private_key_vault.key_vault_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.funcid.principal_id
  secret_permissions = [
    "Get"
  ]
}

resource "azurerm_key_vault_secret" "storage-connection-string" {
  name         = "kvs-${local.base_name}-stconn"
  value        = module.private_storage_account.storage_account_details.primary_connection_string
  key_vault_id = module.private_key_vault.key_vault_id
}
