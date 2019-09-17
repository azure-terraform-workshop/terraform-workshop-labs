output "app-URL" {
  value = "http://${azurerm_public_ip.main.fqdn}"
}
