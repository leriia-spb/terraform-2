terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.54"
    }
  }
}

resource "openstack_lb_listener_v2" "this" {
  name            = var.name
  loadbalancer_id = var.loadbalancer_id
  protocol        = "HTTP"
  protocol_port   = var.protocol_port
}

resource "openstack_lb_pool_v2" "this" {
  listener_id = openstack_lb_listener_v2.this.id
  protocol    = "HTTP"
  lb_method   = "ROUND_ROBIN"
}

resource "openstack_lb_member_v2" "members" {
  count         = length(var.member_addresses)
  pool_id       = openstack_lb_pool_v2.this.id
  address       = var.member_addresses[count.index]
  protocol_port = var.member_port
  subnet_id     = var.subnet_id
}

resource "openstack_lb_monitor_v2" "this" {
  pool_id     = openstack_lb_pool_v2.this.id
  type        = "HTTP"
  delay       = 5
  timeout     = 3
  max_retries = 3
  url_path    = "/"
}
