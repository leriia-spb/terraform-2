terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.54"
    }
  }
}

resource "openstack_lb_loadbalancer_v2" "this" {
  name          = var.name
  vip_subnet_id = var.vip_subnet_id
}

resource "openstack_networking_floatingip_v2" "this" {
  pool = var.external_network_name
}

resource "openstack_networking_floatingip_associate_v2" "this" {
  floating_ip = openstack_networking_floatingip_v2.this.address
  port_id     = openstack_lb_loadbalancer_v2.this.vip_port_id
}

output "id" {
  value = openstack_lb_loadbalancer_v2.this.id
}

output "vip_port_id" {
  value = openstack_lb_loadbalancer_v2.this.vip_port_id
}

output "fip_address" {
  value = openstack_networking_floatingip_v2.this.address
}
