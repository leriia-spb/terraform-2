terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.54"
    }
  }
}

data "openstack_images_image_v2" "this" {
  name        = var.image_name
  most_recent = true
}

resource "openstack_networking_port_v2" "this" {
  count              = var.instance_count
  network_id         = var.network_id
  security_group_ids = [var.security_group_id]

  fixed_ip {
    subnet_id = var.subnet_id
  }
}

resource "openstack_compute_instance_v2" "this" {
  count       = var.instance_count
  name        = "${var.name_prefix}-${count.index}"
  image_id    = data.openstack_images_image_v2.this.id
  flavor_name = var.flavor
  key_pair    = var.keypair_name

  network {
    port = openstack_networking_port_v2.this[count.index].id
  }

  user_data = var.user_data
}

output "private_ips" {
  value = [for p in openstack_networking_port_v2.this : p.all_fixed_ips[0]]
}
