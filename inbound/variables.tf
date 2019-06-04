variable "resource_group_name" {
  description = "The name of the resource group in which the resources will be created"
  default     = "migaraInboundTransit"
}

variable "virtual_network_name" {
  description = "The name of the vnet"
  default     = "weu-inbo-prd-vnet-1"
}

variable "mgmt_subnet_name" {
  description = "The name of the management subnet"
  default     = "weu-trusted-papa-prd-subnt-3"
}

variable "untrust_subnet_name" {
  description = "The name of the untrust subnet"
  default     = "weu-untrust-publ-prd-subnt-1"
}

variable "trust_subnet_name" {
  description = "The name of the trust subnet"
  default     = "weu-trusted-priv-prd-subnt-1"
}
