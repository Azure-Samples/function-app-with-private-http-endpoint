resource "azurerm_network_security_group" "nsg" {
  name                = var.azurerm_network_security_group_name
  resource_group_name = var.resource_group_name
  location            = var.location

  security_rule {
    name                       = "Block_RDP_Internet"
    description                = "Block RDP"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
    access                     = "Deny"
    priority                   = 101
    direction                  = "Inbound"
  }
}

resource "azurerm_network_security_group" "azure_bastion_nsg" {
  name                = "${var.azurerm_network_security_group_name}-bastion"
  resource_group_name = var.resource_group_name
  location            = var.location
}

resource "azurerm_network_security_rule" "azure_bastion_nsg_rule_allow_https_inbound" {
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.azure_bastion_nsg.name
  name                        = "AllowHttpsInbound"
  description                 = "Ingress traffic from public internet"
  direction                   = "Inbound"
  access                      = "Allow"
  priority                    = 120
  protocol                    = "Tcp"
  source_address_prefix       = "Internet"
  source_port_range           = "*"
  destination_address_prefix  = "*"
  destination_port_range      = "443"
}

resource "azurerm_network_security_rule" "azure_bastion_nsg_rule_allow_gateway_mgr_inbound" {
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.azure_bastion_nsg.name
  name                        = "AllowGatewayManagerInbound"
  description                 = "Ingress traffic from Azure Bastion control plane"
  direction                   = "Inbound"
  access                      = "Allow"
  priority                    = 130
  protocol                    = "Tcp"
  source_address_prefix       = "GatewayManager"
  source_port_range           = "*"
  destination_address_prefix  = "*"
  destination_port_range      = "443"
}

resource "azurerm_network_security_rule" "azure_bastion_nsg_rule_allow_azure_lb_inbound" {
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.azure_bastion_nsg.name
  name                        = "AllowAzureLoadBalancerInbound"
  description                 = "Ingress traffic from Azure Load Balancer"
  direction                   = "Inbound"
  access                      = "Allow"
  priority                    = 140
  protocol                    = "Tcp"
  source_address_prefix       = "AzureLoadBalancer"
  source_port_range           = "*"
  destination_address_prefix  = "*"
  destination_port_range      = "443"
}

resource "azurerm_network_security_rule" "azure_bastion_nsg_rule_allow_bastion_host_communication" {
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.azure_bastion_nsg.name
  name                        = "AllowBastionHostCommunication"
  description                 = "Ingress traffic from Azure Bastion data plane"
  direction                   = "Inbound"
  access                      = "Allow"
  priority                    = 150
  protocol                    = "*"
  source_address_prefix       = "VirtualNetwork"
  source_port_range           = "*"
  destination_address_prefix  = "VirtualNetwork"
  destination_port_ranges     = ["8080", "5701"]
}

resource "azurerm_network_security_rule" "azure_bastion_nsg_rule_allow_ssh_rdp_outbound" {
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.azure_bastion_nsg.name
  name                        = "AllowSshRdpOutbound"
  description                 = "Egress traffic to target VMs"
  direction                   = "Outbound"
  access                      = "Allow"
  priority                    = 100
  protocol                    = "*"
  source_address_prefix       = "*"
  source_port_range           = "*"
  destination_address_prefix  = "VirtualNetwork"
  destination_port_ranges     = ["22", "3389"]
}

resource "azurerm_network_security_rule" "azure_bastion_nsg_rule_allow_azure_cloud_outbound" {
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.azure_bastion_nsg.name
  name                        = "AllowAzureCloudOutbound"
  description                 = "Egress traffic to other public endpoints in Azure"
  direction                   = "Outbound"
  access                      = "Allow"
  priority                    = 110
  protocol                    = "Tcp"
  source_address_prefix       = "*"
  source_port_range           = "*"
  destination_address_prefix  = "AzureCloud"
  destination_port_range      = "443"
}

resource "azurerm_network_security_rule" "azure_bastion_nsg_rule_allow_bastion_communication_outbound" {
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.azure_bastion_nsg.name
  name                        = "AllowBastionCommunication"
  description                 = "Egress traffic to Azure Bastion data plane"
  direction                   = "Outbound"
  access                      = "Allow"
  priority                    = 120
  protocol                    = "*"
  source_address_prefix       = "VirtualNetwork"
  source_port_range           = "*"
  destination_address_prefix  = "VirtualNetwork"
  destination_port_ranges     = ["8080", "5701"]
}

resource "azurerm_network_security_rule" "azure_bastion_nsg_rule_allow_get_session_info_outbound" {
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.azure_bastion_nsg.name
  name                        = "AllowGetSessionInformation"
  description                 = "Egress traffic to internet"
  direction                   = "Outbound"
  access                      = "Allow"
  priority                    = 130
  protocol                    = "*"
  source_address_prefix       = "*"
  source_port_range           = "*"
  destination_address_prefix  = "Internet"
  destination_port_range      = "80"
}

resource "azurerm_network_security_group" "private_endpoint_nsg" {
  name                = "${var.azurerm_network_security_group_name}-pe"
  resource_group_name = var.resource_group_name
  location            = var.location
  security_rule       = []
}

resource "azurerm_network_security_group" "app_service_integration_nsg" {
  name                = "${var.azurerm_network_security_group_name}-appServiceInt"
  resource_group_name = var.resource_group_name
  location            = var.location
  security_rule       = []
}
resource "azurerm_virtual_network" "vnet" {
  name                = var.azurerm_virtual_network_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = [var.azurerm_virtual_network_address_space]
}

resource "azurerm_subnet" "bastion" {
  # Azure Bastion requires the subnet to be named "AzureBastionSubnet".
  name                 = "AzureBastionSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.azurerm_subnet_bastion_address_prefixes]
}

resource "azurerm_subnet" "vm" {
  name                 = var.azurerm_subnet_vm_subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.azurerm_subnet_vm_address_prefixes]
}

resource "azurerm_subnet" "app_service_integration" {
  name                 = var.azurerm_subnet_app_service_integration_subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.azurerm_subnet_app_service_integration_address_prefixes]
  service_endpoints    = var.azurerm_subnet_app_service_integration_service_endpoints

  delegation {
    name = "delegation"

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_subnet" "private_endpoints" {
  name                                      = var.azurerm_subnet_private_endpoints_name
  resource_group_name                       = var.resource_group_name
  virtual_network_name                      = azurerm_virtual_network.vnet.name
  address_prefixes                          = [var.azurerm_subnet_private_endpoints_address_prefixes]
  private_endpoint_network_policies_enabled = true
}

resource "azurerm_subnet_network_security_group_association" "nsg_block_rdp" {
  subnet_id                 = azurerm_subnet.vm.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_subnet_network_security_group_association" "nsg_private_endpoints" {
  subnet_id                 = azurerm_subnet.private_endpoints.id
  network_security_group_id = azurerm_network_security_group.private_endpoint_nsg.id
}

resource "azurerm_subnet_network_security_group_association" "nsg_app_service_integration" {
  subnet_id                 = azurerm_subnet.app_service_integration.id
  network_security_group_id = azurerm_network_security_group.app_service_integration_nsg.id
}

resource "azurerm_subnet_network_security_group_association" "nsg_bastion" {
  subnet_id                 = azurerm_subnet.bastion.id
  network_security_group_id = azurerm_network_security_group.azure_bastion_nsg.id

  # https://github.com/hashicorp/terraform-provider-azurerm/issues/5232
  depends_on = [
    azurerm_network_security_rule.azure_bastion_nsg_rule_allow_https_inbound,
    azurerm_network_security_rule.azure_bastion_nsg_rule_allow_gateway_mgr_inbound,
    azurerm_network_security_rule.azure_bastion_nsg_rule_allow_azure_lb_inbound,
    azurerm_network_security_rule.azure_bastion_nsg_rule_allow_bastion_host_communication,
    azurerm_network_security_rule.azure_bastion_nsg_rule_allow_ssh_rdp_outbound,
    azurerm_network_security_rule.azure_bastion_nsg_rule_allow_azure_cloud_outbound,
    azurerm_network_security_rule.azure_bastion_nsg_rule_allow_bastion_communication_outbound,
    azurerm_network_security_rule.azure_bastion_nsg_rule_allow_get_session_info_outbound
  ]
}
