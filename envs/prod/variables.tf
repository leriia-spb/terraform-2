variable "os_username" {
  type = string
}

variable "os_password" {
  type      = string
  sensitive = true
}

variable "os_project_id" {
  type = string
}

variable "os_auth_url" {
  type    = string
  default = "https://infra.mail.ru:35357/v3/"
}

variable "os_region" {
  type    = string
  default = "RegionOne"
}

variable "keypair_name" {
  type        = string
  description = "Имя SSH-ключа в VK Cloud"
}

variable "image_name" {
  type        = string
  description = "Имя образа Ubuntu для ВМ"
  default     = "ubuntu-22-202602051629.gite7a38aaf"
}

variable "flavor" {
  type        = string
  description = "Размер ВМ"
  default     = "Standard-2-4-50"
}
