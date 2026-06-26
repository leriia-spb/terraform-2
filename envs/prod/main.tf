locals {
  template_dir = "${path.module}/../../templates"
  empty        = ""

  backend_nginx_cfg = templatefile("${local.template_dir}/nginx.conf.tftpl", {
    env      = "prod"
    hostname = "be"
  })

  backend_user_data = templatefile("${local.template_dir}/cloud-init.yaml.tftpl", {
    role        = "backend"
    nginx_cfg   = local.backend_nginx_cfg
    haproxy_cfg = local.empty
  })

  frontend_haproxy_cfg = templatefile("${local.template_dir}/haproxy.cfg.tftpl", {
    backend_ips = module.backend.private_ips
  })

  frontend_user_data = templatefile("${local.template_dir}/cloud-init.yaml.tftpl", {
    role        = "frontend"
    nginx_cfg   = local.empty
    haproxy_cfg = local.frontend_haproxy_cfg
  })
}

module "network" {
  source    = "../../modules/network"
  name      = "prod-net"
  cidr      = "10.2.0.0/24"
  router_id = local.shared.router_id
}

module "sg" {
  source = "../../modules/security_group"
  name   = "prod-sg"
  ingress_rules = [
    { protocol = "tcp", port = 22,   cidr = "0.0.0.0/0" },
    { protocol = "tcp", port = 80,   cidr = "0.0.0.0/0" },
    { protocol = "tcp", port = 8080, cidr = "10.17.0.0/24" },
  ]
}

module "backend" {
  source            = "../../modules/compute"
  name_prefix       = "prod-be"
  instance_count    = 2
  image_name        = var.image_name
  flavor            = var.flavor
  keypair_name      = var.keypair_name
  network_id        = module.network.network_id
  subnet_id         = module.network.subnet_id
  security_group_id = module.sg.id
  user_data         = local.backend_user_data
}

module "frontend" {
  source            = "../../modules/compute"
  name_prefix       = "prod-fe"
  instance_count    = 2
  image_name        = var.image_name
  flavor            = var.flavor
  keypair_name      = var.keypair_name
  network_id        = module.network.network_id
  subnet_id         = module.network.subnet_id
  security_group_id = module.sg.id
  user_data         = local.frontend_user_data
}

module "listener" {
  source           = "../../modules/listener"
  name             = "prod-listener"
  loadbalancer_id  = local.shared.loadbalancer_id
  subnet_id        = local.shared.lb_vip_subnet_id
  protocol_port    = 80
  member_port      = 80
  member_addresses = module.frontend.private_ips
}
