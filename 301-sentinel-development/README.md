# Terraform Enterprise - Sentinel Development

##

Clone this repository and cd into this directory `301-sentinel-development`.

## Restrict VM Size Policy

Inspect the file `azurerm-restrict-vm-size.sentinel`.

How is the policy only analyzing Virtual Machines?

### Run a test

To test the policy against our pass and fail tests, run the following command:

```sh
sentinel test azurerm-restrict-vm-size.sentinel

FAIL - azurerm-restrict-vm-size.sentinel
  FAIL - test/azurerm-restrict-vm-size/fail.json
    expected "main" to be false, got: true

    trace:
      TRUE - azurerm-restrict-vm-size.sentinel:68:1 - Rule "main"
        TRUE - azurerm-restrict-vm-size.sentinel:63:2 - all get_resources("azurerm_virtual_machine") as r {
        r.applied.vm_size in allowed_vm_sizes
      }
      
      TRUE - azurerm-restrict-vm-size.sentinel:62:1 - Rule "vm_size_allowed"
  PASS - test/azurerm-restrict-vm-size/pass.json
```

Uh oh!

It looks like our pass.json is succeeding, but our fail.json is not.

Navigate to `test/azurerm-restrict-vm-size` and find the `fail.json` file.

Update the file line 14 from:
  "vm_size": "Standard_D2_V2"
to
  "vm_size": "Standard_D3".

Run the test again.

```sh
sentinel test azurerm-restrict-vm-size.sentinel
PASS - azurerm-restrict-vm-size.sentinel
  PASS - test/azurerm-restrict-vm-size/fail.json
  PASS - test/azurerm-restrict-vm-size/pass.json
```

Success!

Why did updating that file cause the test to pass?

> Hint: Line 52 of file `azurerm-restrict-vm-size.sentinel`

## Extra Credit

Take a look at file `azurerm-block-allow-all-cidr.sentinel` and run its test similar to the policy above.

Can you write a test.json that passes?
