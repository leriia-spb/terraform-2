variable "name" {
  type = string
}

variable "vip_subnet_id" {
  type = string
}

variable "external_network_name" {
  type    = string
  default = "internet"
}
