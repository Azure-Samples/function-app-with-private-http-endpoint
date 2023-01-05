resource "azurerm_public_ip" "pip" {
  name                = var.azurerm_public_ip_name
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "bastion" {
  name                = var.azurerm_bastion_host_name
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                 = "ipConfig"
    subnet_id            = var.azurerm_bastion_host_subnet_id
    public_ip_address_id = azurerm_public_ip.pip.id
  }
}
