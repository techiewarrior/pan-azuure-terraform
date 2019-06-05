variable "resource_group_name" {
  description = "The name of the resource group in which the resources will be created"
  default     = "migaraTransit"
}

variable "virtual_network_name" {
  description = "The name of the vnet"
  default     = "weu-tran-prd-vnet-1"
}

variable "mgmt_subnet_name" {
  description = "The name of the management subnet"
  default     = "weu-trusted-papa-prd-subnt-2"
}

variable "untrust_subnet_name" {
  description = "The name of the untrust subnet"
  default     = "weu-untrust-tran-prd-subnt-1"
}

variable "trust_subnet_name" {
  description = "The name of the trust subnet"
  default     = "weu-trusted-tran-prd-subnt-1"
}

variable "fw_hostname_prefix" {
  description = "Prefix of the firewall hostnames"
  default     = "weupafwdroutfw"
}

variable "fw_size" {
  default = "Standard_D3_v2"
}