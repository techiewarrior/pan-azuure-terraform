provider "panos" {
    hostname = "52.155.171.159"
    username = "fwadmin"
    password = "Paloalto1234"
}

# resource "panos_licensing" "example" {
#     auth_codes = "${list("${var.auth_code}")}"
# }

resource "panos_management_profile" "Azure-Health-Probe" {
    name = "Azure-Health-Probe"
    ssh = true
    permitted_ips = ["168.63.129.16/32"]
}

resource "panos_zone" "untrust" {
    name = "Untrust"
    mode = "layer3"
    interfaces = ["${panos_ethernet_interface.e1.name}"]
    enable_user_id = false
}

resource "panos_zone" "trust" {
    name = "Trust"
    mode = "layer3"
    interfaces = ["${panos_ethernet_interface.e2.name}"]
    enable_user_id = false
}

resource "panos_ethernet_interface" "e1" {
    name = "ethernet1/1"
    vsys = "vsys1"
    mode = "layer3"
    enable_dhcp = true
    create_dhcp_default_route = false
    management_profile = "${var.traffic_flow_direction == "Inbound" ? "${panos_management_profile.Azure-Health-Probe.name}" : "" }"
}

resource "panos_ethernet_interface" "e2" {
    name = "ethernet1/2"
    vsys = "vsys1"
    mode = "layer3"
    enable_dhcp = true
    create_dhcp_default_route = false
    management_profile = "${var.traffic_flow_direction == "Outbound" ? "${panos_management_profile.Azure-Health-Probe.name}" : "" }"
}

resource "panos_virtual_router_entry" "default" {
    count = "${length()}"
    virtual_router = "default"
    interface = [ "ethernet1/1", "ethernet1/2" ]
}
resource "panos_static_route_ipv4" "example" {
    name = "localnet"
    virtual_router = "${panos_virtual_router.vr1.name}"
    destination = "10.1.7.0/32"
    next_hop = "10.1.7.4"
}