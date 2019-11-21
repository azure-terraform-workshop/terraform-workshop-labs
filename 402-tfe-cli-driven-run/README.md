# TFE CLI-driven Run

## Expected Outcome

In this lab, we will invoke a Terraform run on TFE via your local Terraform client (Terraform OSS binary). This is also referred to as the _CLI-driven run_.


## How To

1. In the TFE UI, create a new Workspace. Click `skip this step` within the **Connect to VCS** section. Name the Workspace something unique, such as `tfecli-test-run`.

2. Still in the TFE UI, within the **Variables** section of your newly created TFE Workspace, create the four necessary environment variables for TFE to authenticate to Azure (and mark them as `sensitive`):

```
ARM_SUBSCRIPTION_ID
ARM_CLIENT_ID
ARM_CLIENT_SECRET
ARM_TENANT_ID
```

3. Create a new directory locally on your workstation and create a `main.tf` within it that will provision an Azure Resource Group (or any other basic Azure resource you feel like provisioning - it doesn't really matter what is provisioned for this example):

**main.tf**
```
resource "azurerm_resource_group" "rg" {
  name     = "<unique_user_id>-temp-rg"
  location = "eastus"

  tags = {
    terraform = "true"
  }
}
```
_Note: fill in a unique user id so you don't overlap / cause duplicates with your classmates._

4. Within the same local working directory, create a `backend.tf` file to tell your local Terraform client how to reach your TFE instance:

**backend.tf**
```
terraform {
  backend "remote" {
    hostname     = "tap-tfe.digitalinnovation.dev"
    organization = "<my-tfe-org-name>"

    workspaces {
      name = "<my-tfe-workspace-name>"
    }
  }
}
```

where `hostame` is the hostname of your TFE instance, `organization` is your specific TFE Organization name, and `name` within the workspaces block is your newly created Workspace name.


5. If you still have your TFE API token stashed from one of the previous labs, get ready to copy it. If not, create a new TFE API token in the TFE UI.

6. Create a hidden file named `.terraformrc` in your home directory on your local machine, and add the following stanza:

```
credentials "tap-tfe.digitalinnovation.dev" {
  token = "<my-tfe-api-token>"
}
```

> Note: On Windows, the file must be named named `terraform.rc` and placed in the relevant user's `%APPDATA%` directory. The physical location of this directory depends on your Windows version and system configuration; use `$env:APPDATA` in PowerShell to find its location on your system. 

1. `terraform init`
2. `terraform plan` - refresh the TFE UI and look for the running plan within your TFE Workspace
3. `terraform apply` - refresh the TFE UI and look for the running apply within your TFE Workspace


## Summary
Steps 4-6 are they key concepts with the _CLI-driven run_ method. We need a `backend.tf` file so the local Terraform client knows where to make its API calls against TFE, and we also need a TFE API token so we can properly authenticate to our TFE instance.  It is also important to note that we _did not_ connect our Workspace to a VCS repo.  This is because the Terraform client takes care of compressing and sending the code to the TFE workspace via the TFE API.

This method can be run locally as we just demonstrated, or it can be executed from a build script/ CI pipeline.
