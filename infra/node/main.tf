resource "hcloud_network" "network" {
  name     = "network"
  ip_range = "10.0.0.0/16"
}

resource "hcloud_network_subnet" "subnet" {
  type         = "cloud"
  network_id   = hcloud_network.network.id
  network_zone = "eu-central"
  ip_range     = "10.0.1.0/24"
}

resource "hcloud_primary_ip" "ip" {
  name          = "node-ip"
  datacenter    = "fsn1-dc14"
  type          = "ipv4"
  assignee_type = "server"

  auto_delete = false
}

resource "hcloud_ssh_key" "key" {
  name       = "node-key"
  public_key = file(var.root_key_pub)
}

locals {
  ansible_vars = jsonencode({
    tunnel_token = var.tunnel_token,
    app_key_pub  = var.app_key_pub,
    docker_registry = var.docker_registry,
    docker_user = var.docker_user,
    docker_password = var.docker_password
    node_base_path = var.node_base_path
  })
}

resource "hcloud_server" "node" {
  name        = "node"
  image       = "debian-11"
  server_type = "cax11"
  datacenter  = "fsn1-dc14"

  network {
    network_id = hcloud_network.network.id
    ip         = "10.0.1.1"
  }

  public_net {
    ipv4_enabled = true
    ipv4         = hcloud_primary_ip.ip.id
    ipv6_enabled = true
  }

  ssh_keys = [hcloud_ssh_key.key.id]

  provisioner "local-exec" {
    command = nonsensitive("ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u root -i '${self.ipv4_address},' --private-key ${var.root_key_private} -e '${local.ansible_vars}' ./node/ansible/node_playbook.yml -vvvv")
  }

  depends_on = [
    hcloud_network_subnet.subnet
  ]
}

output "node_ip" {
  value = hcloud_server.node.ipv4_address
}
