variable "name_prefix" {
  type = string
}

variable "instance_count" {
  type    = number
  default = 1
}

variable "image_name" {
  type = string
}

variable "flavor" {
  type = string
}

variable "keypair_name" {
  type = string
}

variable "network_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "security_group_id" {
  type = string
}

variable "user_data" {
  type        = string
  description = "Готовый cloud-init"
  default     = ""
}
