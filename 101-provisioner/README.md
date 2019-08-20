# Using Terraform Provisioner

## Expected Outcome

In this challenge, you will create a Azure Virtual Machine but this time layer in Terraform Provisioners to configure the machines as part the Terraform apply.

## Background

Terraform [provisioners](https://www.terraform.io/docs/provisioners/index.html) help you do additional setup and configuration when a resource is created or destroyed. You can move files, run shell scripts, and install software.

Provisioners are not intended to maintain desired state and configuration for existing resources. For that purpose, you should use one of the many tools for configuration management, such as [Chef](https://www.chef.io/chef/), [Ansible](https://www.ansible.com/), and PowerShell [Desired State Configuration](https://docs.microsoft.com/en-us/powershell/dsc/overview/overview). (Terraform includes a [chef](https://www.terraform.io/docs/provisioners/chef.html) provisioner.)

An imaged-based infrastructure, such as images created with [Packer](https://www.packer.io), can eliminate much of the need to configure resources when they are created. In this common scenario, Terraform is used to provision infrastructure based on a custom image. The image is managed as code.

## How To

### Defining a provisioner

Provisioners are defined on resources, most commonly a new instance of a virtual machine or container.

The complete configuration for this example is given below. By now, you should be familiar with most of the contents.

Notice that the azurerm_virtual_machine resource contains two provisioner blocks:

```hcl
resource "azurerm_virtual_machine" "vm" {

    <...snip...>

    provisioner "file" {
        connection {
            host     = ...
            type     = "ssh"
            user     = "${var.admin_username}"
            password = "${var.admin_password}"
        }

        source      = "newfile.txt"
        destination = "newfile.txt"
    }

    provisioner "remote-exec" {
        connection {
            host     = ...
            type     = "ssh"
            user     = "${var.admin_username}"
            password = "${var.admin_password}"
        }

        inline = [
        "ls -a",
        "cat newfile.txt"
        ]
    }

}

```

As this example shows, you can define more than one provisioner in a resource block. The [file](https://www.terraform.io/docs/provisioners/file.html) and [remote-exec](https://www.terraform.io/docs/provisioners/remote-exec.html) providers are used to perform two simple setup tasks:

-   File copies a text file from the machine that is running Terraform to the new VM instance.
-   Remote-exec runs two commands to list the home folder contents and display the contents of the text file.

Both providers need a [connection](https://www.terraform.io/docs/provisioners/connection.html) to the new virtual machine to do their jobs. To simplify things, the example uses password authentication. In practice, you are more likely to use SSH keys, and for WinRM connections, certificates to authenticate.

This example could be modified to copy a shell script to the new instance and then execute the script, perhaps using arguments derived from environment variables or resource attributes.

### Running provisioners

Provisioners run when a resource is created, or a resource is destroyed. Provisioners do not run during update operations. The example configuration for this section defines two provisioners that run only when a new virtual machine instance is created. If the virtual machine instance is later modified or destroyed, the provisioners will not run.

Although we don't show it in the example configuration, there is a way to define provisioners that run when a resource is destroyed.

The full configuration is:

```hcl
variable "admin_username" {
  default = "plankton"
}
variable "admin_password" {
  default = "Password1234!"
}

variable "resource_prefix" {
  default = "PREFIX" #no dashes or numbers
}

# You'll usually want to set this to a region near you.
variable "location" {
  default = "centralus"
}

# Create a resource group
resource "azurerm_resource_group" "rg" {
  name     = "${var.resource_prefix}TFResourceGroup"
  location = "${var.location}"
}
# Create virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.resource_prefix}TFVnet"
  address_space       = ["10.0.0.0/16"]
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
}

# Create subnet
resource "azurerm_subnet" "subnet" {
  name                 = "${var.resource_prefix}TFSubnet"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  address_prefix       = "10.0.1.0/24"
}

# Create public IP
resource "azurerm_public_ip" "publicip" {
  name                = "${var.resource_prefix}TFPublicIP"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  allocation_method   = "Dynamic"
  domain_name_label   = "${lower(var.resource_prefix)}publicip"
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "nsg" {
  name                = "${var.resource_prefix}TFNSG"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create network interface
resource "azurerm_network_interface" "nic" {
  name                      = "${var.resource_prefix}NIC"
  location                  = "${var.location}"
  resource_group_name       = "${azurerm_resource_group.rg.name}"
  network_security_group_id = "${azurerm_network_security_group.nsg.id}"

  ip_configuration {
    name                          = "${var.resource_prefix}NICConfg"
    subnet_id                     = "${azurerm_subnet.subnet.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.publicip.id}"
  }
}

# Create a Linux virtual machine
resource "azurerm_virtual_machine" "vm" {
  name                  = "${var.resource_prefix}TFVM"
  location              = "${var.location}"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
  network_interface_ids = ["${azurerm_network_interface.nic.id}"]
  vm_size               = "Standard_DS1_v2"

  storage_os_disk {
    name              = "${var.resource_prefix}OsDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04.0-LTS"
    version   = "latest"
  }

  os_profile {
    computer_name  = "${var.resource_prefix}TFVM"
    admin_username = "${var.admin_username}"
    admin_password = "${var.admin_password}"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  provisioner "file" {
    connection {
      host     = "${azurerm_public_ip.publicip.domain_name_label}.centralus.cloudapp.azure.com"
      type     = "ssh"
      user     = "${var.admin_username}"
      password = "${var.admin_password}"
    }

    source      = "newfile.txt"
    destination = "newfile.txt"
  }

  provisioner "remote-exec" {
    connection {
      host     = "${azurerm_public_ip.publicip.domain_name_label}.centralus.cloudapp.azure.com"
      type     = "ssh"
      user     = "${var.admin_username}"
      password = "${var.admin_password}"
    }

    inline = [
      "ls -a",
      "cat newfile.txt"
    ]
  }

}
```

To run the example configuration with provisioners:

1.  Copy the configuration to a file named `main.tf`. It should be the only `.tf` file in the folder.
2.  Create a file named `newfile.txt`. In the editor, add the following text: "Testing the file and remote-exec provisioners." Save the file and close the editor.
3.  Run `terraform init`
4.  Run `terraform plan`
5.  Run `terraform apply`. When prompted to continue, answer `yes`.

The following sample output has been truncated to show only the new output added by the provisioners:

```
azurerm_virtual_machine.vm: Still creating... (1m30s elapsed)
azurerm_virtual_machine.vm: Provisioning with 'file'...
azurerm_virtual_machine.vm: Provisioning with 'remote-exec'...
azurerm_virtual_machine.vm (remote-exec): Connecting to remote host via SSH...
azurerm_virtual_machine.vm (remote-exec):   Host: 13.77.173.240
azurerm_virtual_machine.vm (remote-exec):   User: plankton
azurerm_virtual_machine.vm (remote-exec):   Password: true
azurerm_virtual_machine.vm (remote-exec):   Private key: false
azurerm_virtual_machine.vm (remote-exec):   SSH Agent: false
azurerm_virtual_machine.vm (remote-exec):   Checking Host Key: false
azurerm_virtual_machine.vm (remote-exec): Connected!
azurerm_virtual_machine.vm (remote-exec): .   .bash_logout  .cache       .profile
azurerm_virtual_machine.vm (remote-exec): ..  .bashrc     newfile.txt  .ssh
azurerm_virtual_machine.vm (remote-exec): Testing the file and remote-exec provisioners.
azurerm_virtual_machine.vm: Creation complete after 1m34s (ID: /subscriptions/.../virtualMachines/myTFVM)

Apply complete! Resources: 7 added, 0 changed, 0 destroyed.

```

Continue the procedure from above by doing the following:

1.  Run `terraform show` to examine the current state.
2.  Update your provisioner text file and run a `terraform plan`. Were the results as expected?

### Clean up

When you are done, run `terraform destroy` to remove everything we created

### Failed provisioners and tainted resources

Provisioners sometimes fail to run properly. By the time the provisioner is run, the resource has already been physically created. If the provisioner fails, the resource will be left in an unknown state. When this happens, Terraform will generate an error and mark the resource as "tainted." A resource that is tainted isn't considered safe to use.

When you generate your next execution plan, Terraform will not attempt to restart provisioning on the tainted resource because it isn't guaranteed to be safe. Instead, Terraform will remove any tainted resources and create new resources, attempting to provision them again after creation.

You might wonder why Terraform doesn't destroy the tainted resource during apply, to avoid leaving a resource in an unknown state. Terraform doesn't roll back tainted resources because that action was not in the execution plan. The execution plan says that a resource will be created, but not that it might be deleted. If you create an execution plan with a tainted resource, however, the plan will clearly state that the resource will be destroyed because it is tainted.


### Destroy Provisioners

Provisioners can also be defined that run only during a destroy operation. These are known as [destroy-time provisioners](https://www.terraform.io/docs/provisioners/index.html#destroy-time-provisioners). Destroy provisioners are useful for performing system cleanup, extracting data, etc.

The following code snippet shows how a destroy provisioner is defined:

```
provisioner "remote-exec" {
    when = "destroy"

    <...snip...>

```

