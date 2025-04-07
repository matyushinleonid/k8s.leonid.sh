resource "hcloud_firewall" "worker" {
  name = "worker firewall"

  rule {
    direction   = "in"
    protocol    = "tcp"
    port        = "10250"
    source_ips  = local.all_ips
    description = "Kubelet API"
  }

  rule {
    direction   = "in"
    protocol    = "tcp"
    port        = "10256"
    source_ips  = [var.subnet_cidr]
    description = "kube-proxy"
  }

  rule {
    direction   = "in"
    protocol    = "tcp"
    port        = "30000-32767"
    source_ips  = [var.subnet_cidr]
    description = "NodePort services"
  }

  rule {
    direction   = "in"
    protocol    = "udp"
    port        = "30000-32767"
    source_ips  = [var.subnet_cidr]
    description = "NodePort services"
  }

  rule {
    direction   = "in"
    protocol    = "udp"
    port        = "8472"
    source_ips  = [var.subnet_cidr]
    description = "VXLAN overlay"
  }

}

resource "hcloud_server" "worker-001" {
  name               = "worker-001"
  server_type        = var.server_type
  image              = var.image
  datacenter         = var.datacenter
  placement_group_id = hcloud_placement_group.common.id

  network {
    network_id = hcloud_network.k8s_net.id
    ip         = var.worker-001_internal_ipv4
    alias_ips  = []
  }

  public_net {
    ipv4_enabled = false
    ipv6_enabled = true
  }

  firewall_ids = [
    hcloud_firewall.base.id,
    hcloud_firewall.worker.id
  ]

  ssh_keys = [
    hcloud_ssh_key.common.id
  ]

  depends_on = [
    hcloud_network_subnet.k8s_subnet
  ]
}

# resource "hcloud_server" "worker-002" {
#   name               = "worker-002"
#   server_type        = "ccx13"
#   image              = var.image
#   datacenter         = var.datacenter
#   placement_group_id = hcloud_placement_group.common.id
#
#   network {
#     network_id = hcloud_network.k8s_net.id
#     ip         = var.worker-002_internal_ipv4
#     alias_ips  = []
#   }
#
#   public_net {
#     ipv4_enabled = false
#     ipv6_enabled = true
#   }
#
#   firewall_ids = [
#     hcloud_firewall.base.id,
#     hcloud_firewall.worker.id
#   ]
#
#   ssh_keys = [
#     hcloud_ssh_key.common.id
#   ]
#
#   depends_on = [
#     hcloud_network_subnet.k8s_subnet
#   ]
# }
