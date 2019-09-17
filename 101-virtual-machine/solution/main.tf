variable "prefix" {}

variable "location" {}

resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-vm-rg"
  location = var.location
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "main" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefix       = "10.0.1.0/24"
}

# Linux
resource "azurerm_network_interface" "linux" {
  name                = "${var.prefix}-linuxnic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "config1"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = azurerm_public_ip.linux.id
  }
}

resource "azurerm_virtual_machine" "linux" {
  name                  = "${var.prefix}-linuxvm"
  location              = azurerm_resource_group.main.location
  resource_group_name   = azurerm_resource_group.main.name
  network_interface_ids = [azurerm_network_interface.linux.id]
  vm_size               = "Standard_A2_v2"

  storage_os_disk {
    name              = "${var.prefix}linuxvm-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${var.prefix}linuxvm"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
}

resource "azurerm_public_ip" "linux" {
  name                = "${var.prefix}-linux-pubip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
}

output "linux-private-ip" {
  value       = azurerm_network_interface.linux.private_ip_address
  description = "Linux Private IP Address"
}

output "linux-public-ip" {
  value       = azurerm_public_ip.linux.ip_address
  description = "Linux Public IP Address"
}


# Windows
resource "azurerm_network_interface" "windows" {
  name                = "${var.prefix}-windowsnic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "config1"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = azurerm_public_ip.windows.id
  }
}

resource "azurerm_virtual_machine" "windows" {
  name                  = "${var.prefix}-windowsvm"
  location              = azurerm_resource_group.main.location
  resource_group_name   = azurerm_resource_group.main.name
  network_interface_ids = [azurerm_network_interface.windows.id]
  vm_size               = "Standard_A2_v2"

  storage_os_disk {
    name              = "${var.prefix}windowsvm-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${var.prefix}vm"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
  os_profile_windows_config {}
}

resource "azurerm_public_ip" "windows" {
  name                = "${var.prefix}-windows-pubip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
}

output "windows-private-ip" {
  value       = azurerm_network_interface.windows.private_ip_address
  description = "Windows Private IP Address"
}

output "windows-public-ip" {
  value       = azurerm_public_ip.linux.ip_address
  description = "Windows Public IP Address"
}