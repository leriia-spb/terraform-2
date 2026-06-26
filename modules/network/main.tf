terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.54"
    }
  }
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

output "network_id" {
  value = openstack_networking_network_v2.this.id
}

output "subnet_id" {
  value = openstack_networking_subnet_v2.this.id
}
