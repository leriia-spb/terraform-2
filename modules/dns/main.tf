terraform {
  required_providers {
    vkcs = {
      source  = "vk-cs/vkcs"
      version = "~> 0.9"
    }
  }
}

resource "vkcs_publicdns_zone" "this" {
  zone        = var.zone_name
  primary_dns = "ns1.mcs.mail.ru"
  admin_email = var.admin_email
  ttl         = 3600
}

resource "vkcs_publicdns_record" "a" {
  for_each = { for k, v in var.records : k => v if v.type == "A" }
  zone_id  = vkcs_publicdns_zone.this.id
  type     = "A"
  name     = each.value.name
  ip       = each.value.value
  ttl      = each.value.ttl
}

resource "vkcs_publicdns_record" "cname" {
  for_each = { for k, v in var.records : k => v if v.type == "CNAME" }
  zone_id  = vkcs_publicdns_zone.this.id
  type     = "CNAME"
  name     = each.value.name
  content  = endswith(each.value.value, ".") ? each.value.value : "${each.value.value}."
  ttl      = each.value.ttl
}

output "zone_id" {
  value = vkcs_publicdns_zone.this.id
}

output "zone_name" {
  value = vkcs_publicdns_zone.this.zone
}
