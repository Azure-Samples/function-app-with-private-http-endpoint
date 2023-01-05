resource "azurerm_network_interface" "nic" {
  name                = var.azurerm_network_interface_name
  resource_group_name = var.resource_group_name
  location            = var.location

  ip_configuration {
    name                          = "ipConfig"
    subnet_id                     = var.azurerm_network_interface_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_dev_test_global_vm_shutdown_schedule" "shutdownvm" {
  location              = var.location
  virtual_machine_id    = azurerm_windows_virtual_machine.vm.id
  enabled               = true
  daily_recurrence_time = "1900"
  timezone              = "UTC"

  notification_settings {
    enabled = false
  }
}

resource "azurerm_windows_virtual_machine" "vm" {
  name                = var.azurerm_windows_virtual_machine_name
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.azurerm_windows_virtual_machine_size
  admin_password      = var.azurerm_windows_virtual_machine_admin_password
  admin_username      = var.azurerm_windows_virtual_machine_admin_username
  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}
