module "External-LB" {
  source              = "../modules/loadbalancer"
  name                = "External-LB"
  resource_group_name = "${var.resource_group_name}"
  type                = "public"

  frontend_name   = "Untrust"
  backendpoolname = "Untrust"
  lb_probename    = "TCP-22-inbound"

  "lb_port" {
    TCP-80 = ["80", "tcp", "80"]
  }

  "lb_probe_port" {
    TCP-22-inbound = ["22"]
  }

  "tags" {
    source = "terraform"
    flow = "inbound"
  }
}

module "mgmt-subnet" {
  source               = "../modules/getSubnetID"
  subnet_name          = "${var.mgmt_subnet_name}"
  resource_group_name  = "${var.resource_group_name}"
  virtual_network_name = "${var.virtual_network_name}"
}

module "untrust-subnet" {
  source               = "../modules/getSubnetID"
  subnet_name          = "${var.untrust_subnet_name}"
  resource_group_name  = "${var.resource_group_name}"
  virtual_network_name = "${var.virtual_network_name}"
}

module "trust-subnet" {
  source               = "../modules/getSubnetID"
  subnet_name          = "${var.trust_subnet_name}"
  resource_group_name  = "${var.resource_group_name}"
  virtual_network_name = "${var.virtual_network_name}"
}

module "firewalls" {
  source              = "../modules/firewall"
  resource_group_name = "${var.resource_group_name}"
  azurerm_instances   = "2"

  vnet_subnet_id_mgmt    = "${module.mgmt-subnet.subnet_id}"
  vnet_subnet_id_trust   = "${module.trust-subnet.subnet_id}"
  vnet_subnet_id_untrust = "${module.untrust-subnet.subnet_id}"

  lb_pool_id   = "${module.External-LB.azurerm_lb_backend_address_pool_id}"
  fw_hostname  = "${var.fw_hostname_prefix}"
  fw_size      = "${var.fw_size}"
  os_disk_type = "Standard_LRS"
  "tags" {
    source = "terraform"
    flow = "inbound"
  }
}

# module "test-subnet" {
#   source               = "../modules/getSubnetID"
#   subnet_name          = "test-subnet"
#   resource_group_name  = "migaraAzureSpoke"
#   virtual_network_name = "test-vnet"
# }

# module "Test-VM" {
#   source              = "../modules/testHost"
#   resource_group_name = "migaraAzureSpoke"
#   vnet_subnet_id_vm   = "${module.test-subnet.subnet_id}"
#   hostname            = "Test-VM"
#   admin_password      = "Paloalto123456789"
#   admin_username      = "creator"
#   dns_name            = "ubuntutestvm2"
# }