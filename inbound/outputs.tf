# output "mgmt_subnet_id" {
#   value = "${module.mgmt-subnet.subnet_id}"
# }

# output "untrust_subnet_id" {
#   value = "${module.untrust-subnet.subnet_id}"
# }

# output "trust_subnet_id" {
#   value = "${module.trust-subnet.subnet_id}"
# }

output "fw_public_ips" {
  value = "${module.firewalls.public_ip_address}"
}