# Azure Container Instance

## Expected Outcome

In this challenge, you will learn how to deploy a PaaS solution using Terraform.

There are two docker containers that will be deployed:

- [Hello World](https://github.com/Azure-Samples/aci-helloworld)
    - A simple NodeJS web application that displays a message.
    - Hosted on [Dockerhub](https://hub.docker.com/r/microsoft/aci-helloworld/)
- [Sidecar](https://github.com/Azure-Samples/aci-tutorial-sidecar) 
    - A simple watchdog script that calls the Hello World application every 3 seconds.
    - Hosted on [Dockerhub](https://hub.docker.com/r/microsoft/aci-tutorial-sidecar/)

## How to

### Create Terraform Configuration

Change directory into a folder specific to this challenge.

For example: `cd ~/TerraformWorkshop/container-instance/`.

Create a new file called `main.tf` with the following contents:

**First add the following block to version pin**
```hcl
terraform {
  required_version = ">= 0.12.6"
  required_providers {
    azurerm = "= 1.31"
  }
}
```

On to the good stuff:

```hcl
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
```

### Terraform Init and Plan

Running an `init` should look something like this:

```sh
terraform init

...

Terraform has been successfully initialized!
```

Running a `plan` should look something like this:

```sh
terraform plan
Terraform will perform the following actions:

  + azurerm_container_group.main
      name:                                       "PREFIX-aci-helloworld"
      ...

  + azurerm_resource_group.main
      name:                                       "PREFIX-aci-helloworld"
      ...

  + azurerm_storage_account.main
      name:                                       "<computed>"
      ...

  + azurerm_storage_share.main
      name:                                       "aci-test-share"
      ...


Plan: 4 to add, 0 to change, 0 to destroy.
```

### Terraform Apply

Running an `apply` should look just like a plan except you are prompted for approval to apply.
Type 'yes' and let Terraform build your infrastructure.

### Navigate to the Azure Portal

Open a browser and navigate to the the [Azure Portal](https://portal.azure.com) and you should see your resource group and its resources.
![](img/2018-05-07-18-08-30.png)

### Find the Full Qualified Domain Name

Click into the Azure Container Instance and take note of its FQDN.
![](img/2018-05-07-18-11-33.png)

### Navigate to the Web App

Navigate to that URL and you should see the following:
![](img/2018-05-07-18-13-28.png)

### View the Logs
Back in the Azure Portal, navigate to the Azure Container Instance and view its logs by clicking on the "Containers" tab:
![](img/2018-05-07-18-20-56.png)

Wait a few seconds and refresh the logs, you should see more requests due to the sidecar container.

## A Step Further (optional)

Azure Container Instances also support windows containers!

### Create a Windows Container

Create another resource by adding the following to your existing `main.tf` file:

```hcl
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
  value = azurerm_container_group.windows.fqdn
}
```

:clock1:

### Run Terraform Workflow

Running an `init`, `plan`, and `apply` should yield another Container Instance.

Navigating back to the Azure Portal to get the FQDN and following that URL should get you the very familiar IIS default sites page:
![](img/2018-05-07-18-29-10.png)

## Cleanup

Run a `terraform destroy` when you are done exploring.

## Advanced areas to explore

1. What do you think will happen if you try to combine the Azure Container Instances above (Linux and Windows) into one?
2. Replicate the Terraform above using a single Azure CLI command. Which is easier?

## Resources

- [Azurerm Container Group Docs](https://www.terraform.io/docs/providers/azurerm/r/container_group.html)
- [Azure Container Instances](https://azure.microsoft.com/en-us/services/container-instances)