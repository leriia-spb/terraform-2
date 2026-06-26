module "router" {
  source                = "../../modules/router"
  name                  = "shared-router"
  external_network_name = "internet"
}

module "lb_network" {
  source    = "../../modules/network"
  name      = "lb-net"
  cidr      = "10.17.0.0/24"
  router_id = module.router.id
}

module "loadbalancer" {
  source                = "../../modules/loadbalancer"
  name                  = "shared-lb"
  vip_subnet_id         = module.lb_network.subnet_id
  external_network_name = "internet"
}

module "dns" {
  source      = "../../modules/dns"
  zone_name   = "hw9-${var.student_suffix}.ru"
  admin_email = var.dns_admin_email

  records = {
    prod_a = {
      type  = "A"
      name  = "prod"
      value = module.loadbalancer.fip_address
      ttl   = 60
    }
    prod_www = {
      type  = "CNAME"
      name  = "www.prod"
      value = "prod.hw9-${var.student_suffix}.ru."
      ttl   = 60
    }
    dev_a = {
      type  = "A"
      name  = "dev"
      value = module.loadbalancer.fip_address
      ttl   = 60
    }
    dev_www = {
      type  = "CNAME"
      name  = "www.dev"
      value = "dev.hw9-${var.student_suffix}.ru."
      ttl   = 60
    }
  }
}
