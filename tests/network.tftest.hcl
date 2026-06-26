run "valid_cidr_plan" {
  command = plan

  variables {
    name      = "test-net"
    cidr      = "10.99.0.0/24"
    router_id = "00000000-0000-0000-0000-000000000000"
  }

  assert {
    condition     = openstack_networking_subnet_v2.this.cidr == "10.99.0.0/24"
    error_message = "CIDR не пробрасывается в subnet"
  }
}
