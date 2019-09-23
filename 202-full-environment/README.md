# Full environment example

## Expected Outcome

In this challenge, you will create a small environment with supporting services.

The idea is to use what you have learned so far in the previous labs, along with a bit of research in coming up with a solution that we can share and walk through together.


## Problem statement

You have been tasked with creating terraform that will stand up a standard web environment backed by MS SQL Server or Postgres.  You will then decided the best way to deploy a service and access this database using credentials generated during your terraform run.  You need a log analytics workspace to store analytics for your application, and you want to store your log analytics access key into Azure KeyVault for downstream services to consume and access.


The resources you will use in this challenge:

- Resource Group
- Virtual Network
- Subnets
- [Application service account](https://www.terraform.io/docs/providers/azurerm/r/app_service_plan.html)
- [Application service]()
- SQL Server/Postres database
- Log Analytics Workspace


### Hints ###
* Use the networking infrastructure from the previous labs to create your vnet and subnet.
* The service you deploy is not important as long as it can access your database.  Some suggestions are: 

### Run Terraform Workflow

Run `terraform init` since this is the first time we are running Terraform from this directory.

Run `terraform plan` and validate all resources are being created as desired.

Run `terraform apply` and type `yes` when prompted.

Inspect the infrastructure in the portal.

Access your nginx service with the IP provided.

### Clean up

When you are done, run `terraform destroy` to remove everything we created.
