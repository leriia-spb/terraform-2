variable "name" {
  type = string
}

variable "ingress_rules" {
  type = list(object({
    protocol = string
    port     = number
    cidr     = string
  }))
}
