module "External-LB" {
  source              = "modules/loadbalancer"
  name                = "External-LB"
  resource_group_name = "${var.resource_group_name}"
  type                = "public"

  frontend_name   = "Untrust"
  backendpoolname = "Untrust"
  lb_probename    = "TCP-22"

  "lb_port" {
    TCP-22 = ["22", "tcp", "22"]
  }

  "lb_probe_port" {
    TCP-22 = ["22"]
  }
}

module "mgmt-subnet" {
  source               = "modules/getSubnetID"
  subnet_name          = "${var.mgmt_subnet_name}"
  resource_group_name  = "${var.resource_group_name}"
  virtual_network_name = "${var.virtual_network_name}"
}

module "untrust-subnet" {
  source               = "modules/getSubnetID"
  subnet_name          = "${var.untrust_subnet_name}"
  resource_group_name  = "${var.resource_group_name}"
  virtual_network_name = "${var.virtual_network_name}"
}

module "trust-subnet" {
  source               = "modules/getSubnetID"
  subnet_name          = "${var.trust_subnet_name}"
  resource_group_name  = "${var.resource_group_name}"
  virtual_network_name = "${var.virtual_network_name}"
}

module "firewalls" {
  source              = "modules/firewall"
  resource_group_name = "${var.resource_group_name}"
  azurerm_instances   = "2"

  vnet_subnet_id_mgmt    = "${module.mgmt-subnet.subnet_id}"
  vnet_subnet_id_trust   = "${module.trust-subnet.subnet_id}"
  vnet_subnet_id_untrust = "${module.untrust-subnet.subnet_id}"

  fw_hostname  = "weupafwdrinfw"
  fw_size      = "Standard_D3_v2"
  os_disk_type = "Standard_LRS"
}
