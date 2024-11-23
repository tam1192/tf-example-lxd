# hosts定義
# 参照: https://registry.terraform.io/providers/ansible/ansible/latest/docs/resources/host
resource "ansible_host" "example_ansible_host" {
  count = length(lxd_instance.instance)
  name = element(lxd_instance.instance, count.index).name
  groups = [count.index == 0? "server" : "agent"]
  variables = {
    ansible_host = lxd_network_forward.forward.listen_address
    ansible_port = "220${count.index}"
    ansible_user = "ansible"
    ansible_ssh_private_key_file = "${path.module}/../.ssh/id_ed25519"
    k3s_version = "v1.30.2+k3s1"
    token = "${file("${path.module}/../.ssh/token")}"
    api_endpoint = "192.168.1.10"
  }
}
