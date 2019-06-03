variable "resource_group_name" {
  description = "The name of the resource group in which the resources will be created"
  default     = "terraform_compute"
}

variable "virtual_network_name" {
  description = "The name of the virtual network"
  default     = "terraform_compute"
}

variable "subnet_name" {
  description = "The name of the subnet"
  default     = "terraform_compute"
}
