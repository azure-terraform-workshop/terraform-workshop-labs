
prefix         = "tstraub1"
location       = "centralus"
address_space  = "10.92.0.0/16"
address_prefix = "10.92.1.0/24"
// aci_address_prefix = "10.92.2.0/24"
// monitoring_enabled = true

// kubernetes_version        = "1.13.5"
kubernetes_network_plugin = "azure"
aci_connector_enabled     = true
// agent_pool_type           = "VirtualMachineScaleSets"
agent_pool_os_type      = "Linux"
agent_pool_os_disk_size = 30

default_pool_vm_size = "Standard_D2_v2"
// pool1_vm_size        = "Standard_D3_v2"

enable_rbac                     = false
enable_http_application_routing = false