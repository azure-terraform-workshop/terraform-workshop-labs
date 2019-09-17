resource "tls_private_key" "main" {
  algorithm = "RSA"
}

resource "azurerm_virtual_machine_scale_set" "main" {
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  name                = "${var.prefix}-vmss"
  upgrade_policy_mode = "Manual"

  sku {
    name     = "Standard_F2"
    tier     = "Standard"
    capacity = var.vmss_count
  }

  storage_profile_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_profile_os_disk {
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name_prefix = "${var.prefix}vm"
    admin_username       = var.username
    custom_data          = data.template_file.init.rendered
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/${var.username}/.ssh/authorized_keys"
      key_data = tls_private_key.main.public_key_openssh
    }
  }
  network_profile {
    name    = "NetworkProfile"
    primary = true

    ip_configuration {
      name                                   = "IPConfiguration"
      primary                                = true
      subnet_id                              = azurerm_subnet.main.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.bpepool.id]
      public_ip_address_configuration {
        name              = "${var.prefix}vmsspubip"
        idle_timeout      = 4
        domain_name_label = "${var.prefix}vmsspubip"
      }
    }
  }
}
