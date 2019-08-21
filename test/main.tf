
resource "azurerm_resource_group" "main" {
  name     = "rg-${count.index}"
  location = "centralus"
  count    = 2
}

output "rgs" {
  value = {
    for instance in azurerm_resource_group.main:
    instance.name => instance.location
  }
}