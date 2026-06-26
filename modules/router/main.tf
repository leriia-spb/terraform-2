terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.54"
    }
  }
}

data "openstack_networking_network_v2" "external" {
  name = var.external_network_name
}

resource "openstack_networking_router_v2" "this" {
  name                = var.name
  external_network_id = data.openstack_networking_network_v2.external.id
}

output "id" {
  value = openstack_networking_router_v2.this.id
}

output "external_network_id" {
  value = data.openstack_networking_network_v2.external.id
}
