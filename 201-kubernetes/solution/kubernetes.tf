
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.prefix}-aks"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = var.prefix

  agent_pool_profile {
    name            = "default"
    count           = 1
    os_type         = "Linux"
    os_disk_size_gb = 30
    vm_size         = "Standard_D2_v2"

    vnet_subnet_id = azurerm_subnet.main.id
  }

  service_principal {
    client_id     = var.client_id
    client_secret = var.client_secret
  }
}

resource "local_file" "kube" {
  content  = azurerm_kubernetes_cluster.aks.kube_config_raw
  filename = ".kube/config"

  provisioner "local-exec" {
    
  }
}
