output "router_id" {
  value = module.router.id
}

output "external_network_name" {
  value = "internet"
}

output "loadbalancer_id" {
  value = module.loadbalancer.id
}

output "lb_vip_subnet_id" {
  value = module.lb_network.subnet_id
}

output "fip_address" {
  value = module.loadbalancer.fip_address
}

output "dns_zone_name" {
  value = module.dns.zone_name
}
