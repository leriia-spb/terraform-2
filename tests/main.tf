terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.54"
    }
  }
}

provider "openstack" {
  user_name   = var.os_username
  password    = var.os_password
  tenant_id   = var.os_project_id
  auth_url    = var.os_auth_url
  region      = var.os_region
  domain_name = "users"
}

variable "os_username" {
  type    = string
  default = ""
}

variable "os_password" {
  type      = string
  sensitive = true
  default   = ""
}

variable "os_project_id" {
  type    = string
  default = ""
}

variable "os_auth_url" {
  type    = string
  default = "https://infra.mail.ru:35357/v3/"
}

variable "os_region" {
  type    = string
  default = "RegionOne"
}

variable "name" {
  type    = string
  default = "test-net"
}

variable "router_id" {
  type    = string
  default = "00000000-0000-0000-0000-000000000000"
}

variable "cidr" {
  type    = string
  default = "10.99.0.0/24"
}

resource "openstack_networking_network_v2" "this" {
  name = var.name
}

resource "openstack_networking_subnet_v2" "this" {
  name            = "${var.name}-subnet"
  network_id      = openstack_networking_network_v2.this.id
  cidr            = var.cidr
  ip_version      = 4
  dns_nameservers = ["8.8.8.8", "1.1.1.1"]
}

resource "openstack_networking_router_interface_v2" "this" {
  router_id = var.router_id
  subnet_id = openstack_networking_subnet_v2.this.id
}
