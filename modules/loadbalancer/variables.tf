variable "resource_group_name" {
  description = "The name of the resource group in which the resources will be created"
  default     = "migaraInboundTransit"
}

variable "name" {
  description = "(Required) Default prefix to use with your resource names."
  default     = "azure_public_lb"
}

variable "public_ip_address_allocation" {
  description = "(Required) Defines how an IP address is assigned. Options are Static or Dynamic."
  default     = "Static"
}

variable "tags" {
  type = "map"

  default = {
    source = "terraform"
  }
}

variable "lbsku" {
  default = "Standard"
}

variable "lb_port" {
  description = "Protocols to be used for lb health probes and rules. [frontend_port, protocol, backend_port]"
  type        = "map"
  default     = {}
}

variable "lb_probename" {
  description = "Name of the Load Balancer Probe"
  default     = ""
}

variable "lb_probe_port" {
  description = "Protocols to be used for lb health probes and rules. [frontend_port, protocol, backend_port]"
  default     = {}
}

variable "lb_probe_unhealthy_threshold" {
  description = "Number of times the load balancer health probe has an unsuccessful attempt before considering the endpoint unhealthy."
  default     = 2
}

variable "lb_probe_interval" {
  description = "Interval in seconds the load balancer health probe rule does a check"
  default     = 5
}

variable "floating_ip" {
  default = "true"
}

variable "type" {
  type        = "string"
  description = "(Optional) Defined if the loadbalancer is private or public"
  default     = "public"
}

variable "frontend_subnet_id" {
  description = "(Optional) Frontend subnet id to use when in private mode"
  default     = ""
}

variable "frontend_private_ip_address" {
  description = "(Optional) Private ip address to assign to frontend. Use it with type = private"
  default     = ""
}

variable "frontend_private_ip_address_allocation" {
  description = "(Optional) Frontend ip allocation type (Static or Dynamic)"
  default     = "Dynamic"
}

variable "backendpoolname" {
  description = "Name for the Backendpool where it is configured"
  default     = ""
}

variable "frontend_name" {
  description = "(Required) Specifies the name of the frontend ip configuration."
  default     = ""
}

variable "load_distribution" {
  description = "Option available SourceIPProtocol / None / SourceIP"
  default     = "SourceIPProtocol"
}
