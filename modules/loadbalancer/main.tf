# Azure load balancer module
data "azurerm_resource_group" "rg" {
  name = "${var.resource_group_name}"
}

# Create the public IP address
resource "azurerm_public_ip" "azlb" {
  count               = "${var.type == "public" ? 1 : 0}"
  name                = "${var.name}-publicIP"
  location            = "${data.azurerm_resource_group.rg.location}"
  resource_group_name = "${var.resource_group_name}"
  allocation_method   = "${var.public_ip_address_allocation}"
  sku                 = "Standard"
}

resource "azurerm_lb" "azlb" {
  name                = "${var.name}"
  resource_group_name = "${var.resource_group_name}"
  location            = "${data.azurerm_resource_group.rg.location}"
  tags                = "${var.tags}"
  sku                 = "${var.lbsku}"

  frontend_ip_configuration {
    name                          = "${var.frontend_name}"
    public_ip_address_id          = "${join("",azurerm_public_ip.azlb.*.id)}"
    subnet_id                     = "${var.type == "private" ? "${var.frontend_subnet_id}" : ""}"
    private_ip_address            = "${var.type == "private" ? "${var.frontend_private_ip_address}" : ""}"
    private_ip_address_allocation = "${var.type == "private" ? "${var.frontend_private_ip_address_allocation}" : "dynamic"}"
  }
}

resource "azurerm_lb_backend_address_pool" "lb_backend_pool" {
  resource_group_name = "${var.resource_group_name}"
  loadbalancer_id     = "${azurerm_lb.azlb.id}"
  name                = "${var.backendpoolname}"
}

resource "azurerm_lb_probe" "azlb" {
  count               = "${length(var.lb_port)}"
  resource_group_name = "${var.resource_group_name}"
  loadbalancer_id     = "${azurerm_lb.azlb.id}"
  name                = "${var.lb_probename}"
  port                = "${element(var.lb_probe_port["${element(keys(var.lb_probe_port), count.index)}"], 0)}"
  interval_in_seconds = "${var.lb_probe_interval}"
  number_of_probes    = "${var.lb_probe_unhealthy_threshold}"
}

resource "azurerm_lb_rule" "azlb" {
  count                          = "${length(var.lb_port)}"
  resource_group_name            = "${var.resource_group_name}"
  loadbalancer_id                = "${azurerm_lb.azlb.id}"
  name                           = "${element(keys(var.lb_port), count.index)}"
  protocol                       = "${element(var.lb_port["${element(keys(var.lb_port), count.index)}"], 1)}"
  frontend_port                  = "${element(var.lb_port["${element(keys(var.lb_port), count.index)}"], 0)}"
  backend_port                   = "${element(var.lb_port["${element(keys(var.lb_port), count.index)}"], 2)}"
  frontend_ip_configuration_name = "${var.frontend_name}"
  enable_floating_ip             = "${var.floating_ip}"
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.lb_backend_pool.id}"
  load_distribution              = "${var.load_distribution}"
  idle_timeout_in_minutes        = 5
  probe_id                       = "${element(azurerm_lb_probe.azlb.*.id,count.index)}"
  depends_on                     = ["azurerm_lb_probe.azlb"]
}
