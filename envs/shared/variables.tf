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

variable "student_suffix" {
  type        = string
  description = "Фамилия/логин студента для DNS-зоны"
}

variable "dns_admin_email" {
  type        = string
  description = "Email для DNS-зоны"
  default     = "admin@example.com"
}
