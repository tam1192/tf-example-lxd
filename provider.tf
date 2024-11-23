variable "token" {
    description = "lxdのトークン"
    type = string
}
variable "address" {
    description = "lxdのアドレス"
    type = string
}
variable "name" {
    description = "ユーザー名等"
    type = string
    default = "adw"
}

terraform {
  required_providers {
    lxd = {
      source = "terraform-lxd/lxd"
      version = "2.4.0"
    }
    ansible = {
      source = "ansible/ansible"
      version = "~> 1.3.0"
    }
  }
}
provider "lxd" {
  generate_client_certificates = false
  accept_remote_certificate = false

  remote {
    name = var.name
    address = var.address
    token = var.token
    default = true
  }
  remote {
    name = "ubuntu-hashy"
    protocol = "simplestreams"
    address = "https://mirror.hashy0917.net:443/ubuntu-cloud-images/releases/"
  }
}