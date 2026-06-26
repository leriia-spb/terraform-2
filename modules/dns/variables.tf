variable "zone_name" {
  type = string
}

variable "admin_email" {
  type = string
}

variable "records" {
  type = map(object({
    type  = string
    name  = string
    value = string
    ttl   = number
  }))
  default = {}
}
