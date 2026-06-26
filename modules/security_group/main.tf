terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.54"
    }
  }
}

resource "openstack_networking_secgroup_v2" "this" {
  name = var.name
}

resource "openstack_networking_secgroup_rule_v2" "ingress" {
  for_each = { for r in var.ingress_rules : "${r.protocol}-${r.port}-${r.cidr}" => r }
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = each.value.protocol
  port_range_min    = each.value.port
  port_range_max    = each.value.port
  remote_ip_prefix  = each.value.cidr
  security_group_id = openstack_networking_secgroup_v2.this.id
}

output "id" {
  value = openstack_networking_secgroup_v2.this.id
}
