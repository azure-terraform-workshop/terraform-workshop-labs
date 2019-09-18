# Azure Virtual Machine Scale Set

## Expected Outcome

In this challenge, you will create a kubernetes cluster, and deploy a service, in this case nginx.

The service to deploy is just an  example of how terraform can be used to manage kubernetes resources just like Azure resources.

We will also need to use the client_id and client_secret of your service principal, so keep those values handy.


The resources you will use in this challenge:

- Resource Group
- Virtual Network
- Subnet
- Azure Kubernetes Service (AKS)
- Load Balancer (auto generated)
- Public IP Address (auto generated)
- kubernetes_pod/kubernetes_service

## How to

### Create the base Terraform Configuration

Change directory into a folder specific to this challenge.

For example: `cd ~/TerraformWorkshop/kubernetes/`.

We will start with a few of the basic resources needed.

Create a `core.tf` file to hold our configuration.

Add the folowing to the file:

```hcl
resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-rg"
  location = var.location
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-vnet"
  address_space       = [var.address_space]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "main" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefix       = var.address_prefix
}

```
### Create kubernetes cluster

Create `kubernetes.tf` and add the following configuration:

```

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.prefix}-aks"
  location            = "${azurerm_resource_group.main.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"
  dns_prefix          = "${var.prefix}"

  agent_pool_profile {
    name            = "default"
    count           = 1
    os_type         = "Linux"
    os_disk_size_gb = 30
    vm_size         = "Standard_D2_v2"

    vnet_subnet_id = "${azurerm_subnet.main.id}"
  }

  service_principal {
    client_id     = "${var.client_id}"
    client_secret = "${var.client_secret}"
  }
}

resource "local_file" "foo" {
    content     = "${azurerm_kubernetes_cluster.aks.kube_config_raw}"
    filename = "~/.kube/config"
}

```


### Create Variables

Create a file `variables.tf` and add the following configuration:

```
variable "prefix" {}
variable "location" {}
variable "address_space" {}
variable "address_prefix" {}
variable "name" {}
variable "client_id" {}
variable "client_secret" {}

```

### Supply values for variables

Create a file `terraform.auto.tfvars` and fill in the values.  Use the client_id and client_secret of your service principal used to execute terraform.  Kubernetes needs this to be able to provision load balancers and infrastructure on the clusters behalf:

```
prefix="demo"
name="k8s"
location="eastus2"
address_prefix="10.1.0.0/24"
address_space="10.1.0.0/16"

```
Hint: 

We will want to pass `client_id` and `client_secret` as vars to your terraform plan/applies
### Run Terraform Workflow

Run `terraform init` since this is the first time we are running Terraform from this directory.

Run `terraform plan` and validate all resources are being created as desired.

Run `terraform apply` and type `yes` when prompted.

Inspect the infrastructure in the portal.

Change the node count to another number and replan, does it match your expectations?

### Create kubernetes service to test and access

Create `k8s-services.tf` and add the collowing configuration:

```

resource "kubernetes_pod" "nginx" {
  metadata {
    name = "nginx-example"
    labels = {
      App = "nginx"
    }
  }

  spec {
    container {
      image = "nginx:1.7.8"
      name  = "example"

      port {
        container_port = 80
      }
    }
  }
}

resource "kubernetes_service" "nginx" {
  metadata {
    name = "nginx-example"
  }
  spec {
    selector = {
      App = kubernetes_pod.nginx.metadata[0].labels.App
    }
    port {
      port        = 80
      target_port = 80
    }

    type = "LoadBalancer"
  }
}
```




### Run Terraform Workflow

Run `terraform init` since this is the first time we are running Terraform from this directory.

Run `terraform plan` and validate all resources are being created as desired.

Run `terraform apply` and type `yes` when prompted.

Inspect the infrastructure in the portal.

Change the node count to another number and replan, does it match your expectations?

### Clean up

When you are done, run `terraform destroy` to remove everything we created.
