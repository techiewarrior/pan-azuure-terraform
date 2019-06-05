variable "traffic_flow_direction" {
  description = "Inbound / Outbound"
  default     = "Outbound"
}
variable "auth_code" {
  description = "VM Series Auth Code"
  default     = ""
}

variable "static_routes" {
  type        = "map"
  description = "A map of the static routes to be confoigured."

  default = {
    source = "terraform"
  }
}
