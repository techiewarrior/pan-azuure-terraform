data "azurerm_resource_group" "rg" {
  name = "${var.resource_group_name}"
}

# ********** STORAGE ACCOUNT Firewall **********

# Generate a random id for the storage account due to the need to be unique across azure.
# Here we are generating a random hex value of length 4 (2*2) that is prefixed with
# the static string "sternstorageaccount". For example: sternstorageaccount1n8a
# resource "random_id" "storage_account" {
#   prefix      = "storageaccount"
#   byte_length = "2"
# }

# Create the storage account
# resource "azurerm_storage_account" "storrageaccfw" {
#   name                     = "${lower(random_id.storage_account.hex)}"
#   resource_group_name      = "${var.resource_group_name}"
#   location                 = "${data.azurerm_resource_group.rg.location}"
#   account_replication_type = "${element(split("_", var.boot_diagnostics_sa_type),1)}"
#   account_tier             = "${element(split("_", var.boot_diagnostics_sa_type),0)}"
#   tags                     = "${var.tags}"
# }

# # Create the storage account container
# resource "azurerm_storage_container" "storagecon" {
#   name                  = "vhds"
#   resource_group_name   = "${var.resource_group_name}"
#   storage_account_name  = "${azurerm_storage_account.storrageaccfw.name}"
#   container_access_type = "private"
# }

# # ********** AVAILABILITY SET **********

# # Create the availability set
# resource "azurerm_availability_set" "avset" {
#     name                                = "${var.avsetname}"
#     location                            = "${azurerm_resource_group.vm.location}"
#     resource_group_name                 = "${var.resource_group_name}"
#     platform_update_domain_count        = 5
#     platform_fault_domain_count         = 3
# }

# Create managed data disk for firewalls deployed in Availability Zones
# resource "azurerm_managed_disk" "firewall" {
#   count                = "${var.azurerm_instances}"
#   name                 = "${var.fw_hostname}${count.index+1}-MD02"
#   location             = "${data.azurerm_resource_group.rg.location}"
#   resource_group_name  = "${var.resource_group_name}"
#   storage_account_type = "${var.storage_acount_type}"
#   create_option        = "Empty"
#   disk_size_gb         = "${var.disk_size_gb}"
#   zones                = "${list("${element("${list("1","2")}", count.index)}")}"
# }

# ********** VM PUBLIC IP ADDRESSES FOR MANAGEMENT **********

# Create the public IP address
resource "azurerm_public_ip" "pip" {
  count               = "${var.azurerm_instances}"
  name                = "${var.fw_hostname}${count.index+1}-publicIP"
  location            = "${data.azurerm_resource_group.rg.location}"
  resource_group_name = "${var.resource_group_name}"
  allocation_method   = "Static"
  sku                 = "Standard"
}

# ********** NSG for the Public IP **********

# Create NSG
resource "azurerm_network_security_group" "open" {
  name                = "Allow-Any"
  location            = "${data.azurerm_resource_group.rg.location}"
  resource_group_name = "${var.resource_group_name}"

  # Create Security Rules

  security_rule {
    name                       = "Deafult-Allow-Any"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "ssh" {
  name                = "mgmt"
  location            = "${data.azurerm_resource_group.rg.location}"
  resource_group_name = "${var.resource_group_name}"

  security_rule {
    name                       = "ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "https"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# ********** VM NETWORK INTERFACES **********

# Create the network interfaces
resource "azurerm_network_interface" "Management" {
  count               = "${var.azurerm_instances}"
  name                = "${var.fw_hostname}${count.index+1}-mgmt"
  location            = "${data.azurerm_resource_group.rg.location}"
  resource_group_name = "${var.resource_group_name}"

  ip_configuration {
    name                          = "${var.fw_hostname}${count.index+1}-ip-0"
    subnet_id                     = "${var.vnet_subnet_id_mgmt}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${element(azurerm_public_ip.pip.*.id, count.index)}"
  }

  network_security_group_id = "${azurerm_network_security_group.ssh.id}"
}

# Create the network interfaces
resource "azurerm_network_interface" "Trust" {
  count                = "${var.azurerm_instances}"
  name                 = "${var.fw_hostname}${count.index+1}-trust"
  location             = "${data.azurerm_resource_group.rg.location}"
  resource_group_name  = "${var.resource_group_name}"
  enable_ip_forwarding = "${var.enable_ip_forwarding}"

  ip_configuration {
    name                                    = "${var.fw_hostname}${count.index+1}-ip-0"
    subnet_id                               = "${var.vnet_subnet_id_trust}"
    private_ip_address_allocation           = "Dynamic"
    load_balancer_backend_address_pools_ids = ["${var.lb_backend_pool_trust}"]
  }

  network_security_group_id = "${azurerm_network_security_group.open.id}"
}

# Create the network interfaces
resource "azurerm_network_interface" "Untrust" {
  count                = "${var.azurerm_instances}"
  name                 = "${var.fw_hostname}${count.index+1}-untrust"
  location             = "${data.azurerm_resource_group.rg.location}"
  resource_group_name  = "${var.resource_group_name}"
  enable_ip_forwarding = "${var.enable_ip_forwarding}"

  ip_configuration {
    name                                          = "${var.fw_hostname}${count.index+1}-ip-0"
    subnet_id                                     = "${var.vnet_subnet_id_untrust}"
    private_ip_address_allocation                 = "Dynamic"
    load_balancer_backend_address_pools_ids       = ["${var.lb_backend_pool_untrust}"]
    application_gateway_backend_address_pools_ids = ["${var.appgw_backend_pool}"]
  }

  network_security_group_id = "${azurerm_network_security_group.open.id}"
}

# ********** VIRTUAL MACHINE CREATION **********

# Create the virtual machine. Use the "count" variable to define how many to create.
resource "azurerm_virtual_machine" "firewall" {
  count               = "${var.azurerm_instances}"
  name                = "${var.fw_hostname}${count.index+1}"
  location            = "${data.azurerm_resource_group.rg.location}"
  resource_group_name = "${var.resource_group_name}"

  network_interface_ids = [
    "${element(azurerm_network_interface.Management.*.id, count.index)}",
    "${element(azurerm_network_interface.Untrust.*.id, count.index)}",
    "${element(azurerm_network_interface.Trust.*.id, count.index)}",
  ]

  primary_network_interface_id = "${element(azurerm_network_interface.Management.*.id, count.index)}"
  vm_size                      = "${var.fw_size}"

  # availability_set_id           = "${azurerm_availability_set.avset.id}"
  zones = "${list("${element("${list("1","2")}", count.index)}")}"

  storage_image_reference {
    publisher = "${var.vm_publisher}"
    offer     = "${var.vm_series}"
    sku       = "${var.fw_sku}"
    version   = "${var.fw_version}"
  }

  plan {
    name      = "${var.fw_sku}"
    product   = "${var.vm_series}"
    publisher = "${var.vm_publisher}"
  }

  storage_os_disk {
    name = "pa-vm-os-disk-${count.index+1}"

    # vhd_uri       = "${azurerm_storage_account.storrageaccfw.primary_blob_endpoint}${element(azurerm_storage_container.storagecon.*.name, count.index)}/fwDisk${count.index+1}.vhd"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "${var.os_disk_type}"
  }

  # storage_data_disk {
  #   name            = "${azurerm_managed_disk.firewall.*.name[count.index]}"
  #   managed_disk_id = "${azurerm_managed_disk.firewall.*.id[count.index]}"
  #   create_option   = "Attach"
  #   lun             = 1
  #   disk_size_gb    = "${azurerm_managed_disk.firewall.*.disk_size_gb[count.index]}"
  # }

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true
  os_profile {
    computer_name  = "${var.fw_hostname}${count.index+1}"
    admin_username = "${var.adminUsername}"
    admin_password = "${var.adminPassword}"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
}
