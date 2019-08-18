resource "azurerm_public_ip" "main" {
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  name                = "${var.prefix}-pubip"
  allocation_method   = "Static"
  # sku                 = local.lb_sku
  # domain_name_label   = "${var.prefix}-${random_pet.endpoint.id}"
}

resource "azurerm_lb" "main" {
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  name                = "${var.prefix}-lb"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.main.id
  }
}

resource "azurerm_lb_backend_address_pool" "bpepool" {
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  loadbalancer_id     = azurerm_lb.main.id
  name                = "BackEndAddressPool"
}

resource "azurerm_lb_rule" "lb-app" {
  resource_group_name            = azurerm_resource_group.main.name
  loadbalancer_id                = azurerm_lb.main.id
  backend_address_pool_id        = azurerm_lb_backend_address_pool.bpepool.id
  probe_id                       = azurerm_lb_probe.http.id
  name                           = "AppRule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicIPAddress"
}

resource "azurerm_lb_probe" "http" {
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  loadbalancer_id     = azurerm_lb.main.id
  name                = "ptfe-app-http-probe"
  protocol            = "Http"
  request_path        = "/_health_check"
  port                = 80
}