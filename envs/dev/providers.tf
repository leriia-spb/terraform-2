terraform {
  required_version = ">= 1.6"

  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.54"
    }
    vkcs = {
      source  = "vk-cs/vkcs"
      version = "~> 0.9"
    }
  }
}

provider "openstack" {
  user_name   = var.os_username
  password    = var.os_password
  tenant_id   = var.os_project_id
  auth_url    = var.os_auth_url
  region      = var.os_region
  domain_name = "users"
}

provider "vkcs" {
  username   = var.os_username
  password    = var.os_password
  project_id = var.os_project_id
  region     = var.os_region
  auth_url   = var.os_auth_url
}
