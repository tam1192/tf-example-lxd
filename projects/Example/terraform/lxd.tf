# Projectの定義
# 参照: https://registry.terraform.io/providers/terraform-lxd/lxd/latest/docs/resources/project
resource "lxd_project" "example" {
  name = var.project.name
  config = {
    "features.images" = "true"
    "features.networks" = "true"
    "features.networks.zones" = "true"
    "features.profiles" = "true"
    "features.storage.buckets" = "true"
    "features.storage.volumes" = "true"
  }
}

# Networkの定義
# 参照: https://registry.terraform.io/providers/terraform-lxd/lxd/latest/docs/resources/network
resource "lxd_network" "network" {
  name = "default"
  type = "ovn"
  project = lxd_project.example.name
  config = {
    "network" = "GLOBAL_UPLINK"
    "ipv4.address" ="192.168.1.1/24"
    "ipv4.nat" = "true"
  }
}


# imageの定義
# 参照: https://registry.terraform.io/providers/terraform-lxd/lxd/latest/docs/resources/cached_image
resource "lxd_cached_image" "image" {
  source_remote = "ubuntu-hashy"
  source_image = "24.04"
  type = "virtual-machine"
  project = lxd_project.example.name
}

# Profileの定義
# 参照: https://registry.terraform.io/providers/terraform-lxd/lxd/latest/docs/resources/profile
# このプロフィールではcpu,ram,nic,diskを管理する
resource "lxd_profile" "resource" {
  name = "resource_example"
  project = lxd_project.example.name
  config = {
    "limits.cpu" = "2"
    "limits.memory" = "4GiB"
  }
  device {
    name = "root"
    type = "disk"
    properties = {
      "pool" = "remote"
      "path" = "/"
      "size" = "16GiB"
    }
  }
}

# Profileの定義2
# 参照: https://registry.terraform.io/providers/terraform-lxd/lxd/latest/docs/resources/profile
# このプロフィールではcloud-initを制御する
resource "lxd_profile" "cloud-init" {
  name = "cloud_init_example"
  project = lxd_project.example.name
  config = {
    "cloud-init.user-data" = <<-EOF
    #cloud-config
    ssh_pwauth: false
    users:
    - name: "tam1192"
      lock_passwd: true
      groups: users,admin,wheel
      shell: "/bin/bash"
      ssh_import_id:
      - "gh:tam1192"
    - name: ansible
      groups: users,admin,wheel
      sudo: ALL=(ALL) NOPASSWD:ALL
      shell: /bin/bash
      lock_passwd: true
      ssh_authorized_keys:
      - "${file("${path.module}/../.ssh/id_ed25519.pub")}"
    apt:
      sources_list: |
        Types: deb
        URIs: https://mirror.hashy0917.net/ubuntu/
        Suites: $RELEASE
        Components: main
    package_update: true
    package_upgrade: true
    packages:
    - "git"
    - "openssh-server"
    EOF
  }
}

# instanceの定義
# 参照: https://registry.terraform.io/providers/terraform-lxd/lxd/latest/docs/resources/instance
resource "lxd_instance" "instance" {
  count = 3
  name = "ex-instance-${count.index}"
  image = format("%s:%s", lxd_cached_image.image.source_remote, lxd_cached_image.image.source_image)
  type = "virtual-machine"
  project = lxd_project.example.name
  profiles = [lxd_profile.resource.name, lxd_profile.cloud-init.name]

  device {
    name = "eth0"
    type = "nic"
    properties = {
      "network"   = lxd_network.network.name
      "ipv4.address" = "192.168.1.1${count.index}"
    }
  }

}

# forwardの定義
# 参照: https://registry.terraform.io/providers/terraform-lxd/lxd/latest/docs/resources/network_forward
resource "lxd_network_forward" "forward" {
  network = lxd_network.network.name
  listen_address = "192.168.10.50"
  project = lxd_project.example.name

  ports = concat([for i in range(length(lxd_instance.instance)): {
      description = "SSH-node${i}"
      protocol = "tcp"
      listen_port = "220${i}"
      target_port = "22"
      target_address = "192.168.1.1${i}"
  }], [{
      description = "k3s"
      protocol = "tcp"
      listen_port = "6443"
      target_port = "6443"
      target_address = "192.168.1.10"
  }])
}
