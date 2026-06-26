variable "name" {
  type = string
}

variable "loadbalancer_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "member_addresses" {
  type = list(string)
}

variable "member_port" {
  type    = number
  default = 80
}

variable "protocol_port" {
  type = number
  validation {
    condition     = var.protocol_port > 0 && var.protocol_port < 65536
    error_message = "protocol_port должен быть в диапазоне 1..65535."
  }
}
