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
module "Internal-LB" {
  source              = "../modules/loadbalancer"
  name                = "Internal-LB"
  resource_group_name = "${var.resource_group_name}"
  type                = "private"

  frontend_name   = "Trust"
  backendpoolname = "Trust"
  lb_probename    = "ssh"

  frontend_subnet_id = "${module.trust-subnet.subnet_id}"

  "lb_port" {
    HA  = ["0", "All", "0"]
  }

  "lb_probe_port" {
    ssh = ["22"]
  }
}


module "firewalls" {
  source              = "../modules/firewall"
  resource_group_name = "${var.resource_group_name}"
  azurerm_instances   = "2"
  traffic_direction = "Outbound"
  vnet_subnet_id_mgmt    = "${module.mgmt-subnet.subnet_id}"
  vnet_subnet_id_trust   = "${module.trust-subnet.subnet_id}"
  vnet_subnet_id_untrust = "${module.untrust-subnet.subnet_id}"

  lb_pool_id   = "${module.Internal-LB.azurerm_lb_backend_address_pool_id}"
  fw_hostname  = "${var.fw_hostname_prefix}"
  fw_size      = "${var.fw_size}"
  os_disk_type = "Standard_LRS"
}
