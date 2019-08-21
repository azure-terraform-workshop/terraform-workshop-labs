terraform {
  required_version = ">= 0.12.6"
  required_providers {
    azurerm = "= 1.31"
  }
}

resource "random_integer" "main" {
  min = 500
  max = 50000
}

resource "azurerm_resource_group" "main" {
  name     = "PREFIX-aci-helloworld"
  location = "centralus"
}

resource "azurerm_storage_account" "main" {
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  name                     = "acidev${random_integer.main.result}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_share" "main" {
  resource_group_name  = azurerm_resource_group.main.name
  storage_account_name = azurerm_storage_account.main.name
  name                 = "aci-test-share"
  quota                = 1
}

resource "azurerm_container_group" "main" {
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  name                = "aci-helloworld"
  ip_address_type     = "public"
  dns_name_label      = "aci-${random_integer.main.result}"
  os_type             = "linux"

  container {
    name   = "helloworld"
    image  = "microsoft/aci-helloworld"
    cpu    = "0.5"
    memory = "1.5"
    ports {
      port     = 80
      protocol = "TCP"
    }

    environment_variables = {
      "NODE_ENV" = "testing"
    }

    volume {
      name       = "logs"
      mount_path = "/aci/logs"
      read_only  = false
      share_name = azurerm_storage_share.main.name

      storage_account_name = azurerm_storage_account.main.name
      storage_account_key  = azurerm_storage_account.main.primary_access_key
    }
  }

  container {
    name   = "sidecar"
    image  = "microsoft/aci-tutorial-sidecar"
    cpu    = "0.5"
    memory = "1.5"
  }

  tags = {
    environment = "testing"
  }
}

output "aci-helloworld-fqdn" {
  value = azurerm_container_group.main.fqdn
}

resource "azurerm_container_group" "windows" {
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  name                = "aci-iis"
  ip_address_type     = "public"
  dns_name_label      = "aci-iis-${random_integer.main.result}"
  os_type             = "windows"

  container {
    name   = "dotnetsample"
    image  = "microsoft/iis"
    cpu    = "0.5"
    memory = "1.5"
    ports {
      port     = 80
      protocol = "TCP"
    }
  }

  tags = {
    environment = "testing"
  }
}

output "aci-iis-fqdn" {
  value = "http://${azurerm_container_group.windows.fqdn}"
}
