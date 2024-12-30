resource "hcloud_ssh_key" "ssh_key" {
  name       = "ssh-key"
  public_key = file("~/.ssh/hcloud.pub")
}

resource "hcloud_server" "cpl_node_1" {
  name        = "cpl-node-1"
  server_type = var.server_type
  image       = var.image
  datacenter  = var.datacenter

  network {
    network_id = hcloud_network.k8s_net.id
    ip         = var.cpl_internal_ipv4
    alias_ips  = []
  }

  public_net {
    ipv4_enabled = false
    ipv6_enabled = true
  }

  firewall_ids = [
    hcloud_firewall.basic_firewall.id,
    hcloud_firewall.k8s_cpl_firewall.id,
    hcloud_firewall.lb_firewall.id
  ]

  ssh_keys = [
    hcloud_ssh_key.ssh_key.id
  ]

  depends_on = [
    hcloud_network_subnet.k8s_subnet
  ]
}

resource "hcloud_server" "worker_node_1" {
  name        = "worker-node-1"
  server_type = var.server_type
  image       = var.image
  datacenter  = var.datacenter

  network {
    network_id = hcloud_network.k8s_net.id
    ip         = var.worker_internal_ipv4
    alias_ips  = []
  }

  public_net {
    ipv4_enabled = false
    ipv6_enabled = true
  }

  firewall_ids = [
    hcloud_firewall.basic_firewall.id,
    hcloud_firewall.k8s_worker_firewall.id
  ]

  ssh_keys = [
    hcloud_ssh_key.ssh_key.id
  ]

  depends_on = [
    hcloud_network_subnet.k8s_subnet
  ]
}
