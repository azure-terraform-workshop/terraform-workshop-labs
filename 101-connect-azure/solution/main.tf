provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "main" {
  name     = "tstraub-myfirstrg"
  location = "centralus"

  tags = {
    terraform = "true"
  }
}

resource "azurerm_resource_group" "count" {
  name     = "tstraub-myfirstrg-${count.index}"
  location = "centralus"
  count    = 2
  
  tags = {
    terraform = "true"
  }
}
