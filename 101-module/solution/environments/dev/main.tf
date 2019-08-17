locals {
  username = "someadmin"
  password = "Password1234!"
}
module "myawesomewindowsvm" {
  source   = "../../modules/my_virtual_machine"
  prefix   = "PREFIX"
  vm_size  = "Standard_A2_v2"
  username = local.username
  password = local.password
}

module "differentwindowsvm" {
  source   = "../../modules/my_virtual_machine"
  prefix   = "MOREPREFIX"
  vm_size  = "Standard_A2_v2"
  username = local.username
  password = local.password
}
