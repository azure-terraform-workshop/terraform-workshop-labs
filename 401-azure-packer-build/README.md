# Packer Build on Azure

## Expected Outcome

In this lab, you will create a custom Azure VM Image using HashiCorp Packer.  This image will be for Python Flask web application server.


## How To

### ONE PERSON ONLY
1.  Create an Azure Resource Group dedicated just for this Packer lab for the class.
```
export ARM_LOCATION="eastus"
export ARM_RESOURCE_GROUP="AZR-PACKER-DEMO-RG"
az group create -l ${ARM_LOCATION} -n ${ARM_RESOURCE_GROUP}
```

_(Note: we could also create this Resource Group using Terraform if we want - whichever is quicker)_

### EVERYBODY
2. Download and install Packer (https://www.packer.io/downloads.html).

3. Be sure you have the following environment variables set in your shell:
```
export ARM_SUBSCRIPTION_ID=
export ARM_CLIENT_ID=
export ARM_CLIENT_SECRET=
```

4. `cd` into `./templates` and execute the Packer build:
```
packer validate ./web_server.json
packer build -var 'user_id=<my unique user_id> ./web_server.json
```

_Note: the `user_id` variable is only for distinguising the name of your Packer image from your classmates' images and ensuring uniqueness._

5. Go to the Azure GUI and view the newly created VM image.

