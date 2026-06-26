variable "name" {
  type = string
}

variable "router_id" {
  type = string
}

variable "cidr" {
  type = string
  validation {
    condition     = can(cidrnetmask(var.cidr))
    error_message = "cidr должен быть валидным IPv4 CIDR."
  }
}
