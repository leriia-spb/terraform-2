locals {
  template_dir = "${path.module}/../../templates"
  empty        = ""

  dev_nginx_cfg = templatefile("${local.template_dir}/nginx.conf.tftpl", {
    env      = "dev"
    hostname = "node"
  })

  dev_haproxy_cfg = templatefile("${local.template_dir}/haproxy.cfg.tftpl", {
    backend_ips = local.dev_backend_ips
  })

  dev_user_data = templatefile("${local.template_dir}/cloud-init.yaml.tftpl", {
    role        = "both"
    nginx_cfg   = local.dev_nginx_cfg
    haproxy_cfg = local.dev_haproxy_cfg
  })
}

module "network" {
  source    = "../../modules/network"
  name      = "dev-net"
  cidr      = "10.25.0.0/24"
  router_id = local.shared.router_id
}

module "sg" {
  source = "../../modules/security_group"
  name   = "dev-sg"
  ingress_rules = [
    { protocol = "tcp", port = 22,    cidr = "0.0.0.0/0" },
    { protocol = "tcp", port = 80,    cidr = "0.0.0.0/0" },
    { protocol = "tcp", port = 8080,  cidr = "0.0.0.0/0" },
    { protocol = "tcp", port = 8080,  cidr = "10.17.0.0/24" },
  ]
}

module "node" {
  source            = "../../modules/compute"
  name_prefix       = "dev-node"
  instance_count    = 2
  image_name        = var.image_name
  flavor            = var.flavor
  keypair_name      = var.keypair_name
  network_id        = module.network.network_id
  subnet_id         = module.network.subnet_id
  security_group_id = module.sg.id
  user_data         = local.dev_user_data
}

module "listener" {
  source           = "../../modules/listener"
  name             = "dev-listener"
  loadbalancer_id  = local.shared.loadbalancer_id
  subnet_id        = local.shared.lb_vip_subnet_id
  protocol_port    = 8080
  member_port      = 80
  member_addresses = module.node.private_ips
}
