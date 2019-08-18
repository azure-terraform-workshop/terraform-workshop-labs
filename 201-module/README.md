# 05 - Terraform Modules

## Expected Outcome

In this challenge, you will create a module to contain a scalable virtual machine deployment, then create an environment where you will call the module.

## How to

### Create Folder Structure

Change directory into a folder specific to this challenge.

For example: `cd ~/TerraformWorkshop/vm-module/`.

In order to organize your code, create the following folder structure with `main.tf` files.

```sh
├── environments
│   └── dev
│       └── main.tf
└── modules
    └── my_virtual_machine
        └── main.tf
```

### Create the Module

Inside the `my_virtual_machine` module folder copy over the terraform configuration from virtual machine lab.
This will give you a great starting point.

### Create Variables

Extract name, vm size, username and password into variables without defaults.

This will result in them being required.

```hcl
variable "name" {}
variable "vm_size" {}
variable "username" {}
variable "password" {}
```

> Extra credit: How many other variables can you extract?

### Create the Environment

Change your working directory to the `environments/dev` folder.

Update main.tf to declare your module, it could look similar to this:

```hcl
module "myawesomewindowsvm" {
  source = "../../modules/my_virtual_machine"
}
```

> Notice the relative module sourcing.

### Terraform Init

Run `terraform init`.

```sh
Initializing modules...
- module.myawesomewindowsvm
  Getting source "../../modules/my_virtual_machine"
```

### Terraform Plan

Run `terraform plan`.

```sh
Error: Missing required argument

  on main.tf line 2, in module "myawesomewindowsvm":
   2: module "myawesomewindowsvm" {

The argument "prefix" is required, but no definition was found.


Error: Missing required argument

  on main.tf line 2, in module "myawesomewindowsvm":
   2: module "myawesomewindowsvm" {

The argument "vm_size" is required, but no definition was found.


Error: Missing required argument

  on main.tf line 2, in module "myawesomewindowsvm":
   2: module "myawesomewindowsvm" {

The argument "username" is required, but no definition was found.


Error: Missing required argument

  on main.tf line 2, in module "myawesomewindowsvm":
   2: module "myawesomewindowsvm" {

The argument "password" is required, but no definition was found.
```

We have a problem! We didn't set required variables for our module.

Update the `main.tf` file:

```hcl
module "myawesomewindowsvm" {
  source   = "../../modules/my_virtual_machine"
  prefix   = "PREFIX"
  vm_size  = "Standard_A2_v2"
  username = "someadmin"
  password = "Password1234!"
}
```

Run `terraform plan` again, this time there should not be any errors and you should see your VM built from your module.

```sh
  + module.myawesomewindowsvm.azurerm_resource_group.module
      id:                                 <computed>
      location:                           "centralus"
      name:                               "awesomeapp-rg"

...

Plan: 6 to add, 0 to change, 0 to destroy.
```

## Add Another Module

Add another `module` block describing another set of Virtual Machines:

```hcl
module "differentwindowsvm" {
  source = "../../modules/my_virtual_machine"
  name   = "differentapp"
  vm_size  = "Standard_A2_v2"
  username = "${var.username}"
  password = "${var.password}"
}
```

## Terraform Plan

Since we added another module call, we must run `terraform init` again before running `terraform plan`.

We should see twice as much infrastructure in our plan.

```sh
  # module.myawesomewindowsvm.azurerm_resource_group.main will be created
  + resource "azurerm_resource_group" "main" {
      + id       = (known after apply)
      + location = "centralus"
      + name     = "PREFIX-rg"
      + tags     = (known after apply)
    }

...

  # module.differentwindowsvm.azurerm_resource_group.main will be created
  + resource "azurerm_resource_group" "main" {
      + id       = (known after apply)
      + location = "centralus"
      + name     = "MOREPREFIX-rg"
      + tags     = (known after apply)
    }

...

Plan: 12 to add, 0 to change, 0 to destroy.

```

## More Variables

In your `environments/dev/main.tf` file we can see some duplication and secrets we do not want to store in configuration.

Add two local variables to your environment `main.tf` file for username and password.

```hcl
locals {
  username = "someadmin"
  password = "Password1234!"
}
```

Now reference them in the module blocks:

```hcl
module "myawesomewindowsvm" {
  ...
  username = local.username
  password = local.password
}

module "differentwindowsvm" {
  ...
  username = local.username
  password = local.password
}
```

## Terraform Plan

Run `terraform plan` and verify that your plan succeeds and looks the same.

> Note: Feel free to apply this infrastructure to validate the workflow. Be sure to destroy when you are done.

## Advanced areas to explore

1. Use environment variables to load your secrets.
2. Add a reference to the Public Terraform Module for [Azure Compute](https://registry.terraform.io/modules/Azure/compute/azurerm)

## Resources

- [Using Terraform Modules](https://www.terraform.io/docs/modules/usage.html)
- [Source Terraform Modiules](https://www.terraform.io/docs/modules/sources.html)
- [Public Module Registry](https://www.terraform.io/docs/registry/index.html)
