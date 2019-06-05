output "fw_public_ips" {
  value = "${module.firewalls.public_ip_address}"
}
