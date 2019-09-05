locals {
  username = "someadmin"
  password = "Password1234!"
}

module "myawesomewindowsvm" {
  source   = "../../modules/my_virtual_machine"
  prefix   = "${var.prefix}"
  address_prefix = "${var.address_prefix}"
  address_space = "${var.address_space}"
  vm_size  = "Standard_A2_v2"
  username = local.username
  password = local.password
}

module "differentwindowsvm" {
  source   = "../../modules/my_virtual_machine"
  prefix   = var.prefix
  address_prefix = "${var.address_prefix}"
  address_space = "${var.address_space}"
  vm_size  = "Standard_A2_v2"
  username = local.username
  password = local.password
}
