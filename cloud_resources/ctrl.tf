resource "hcloud_firewall" "ctrl" {
  name = "ctrl plane firewall"

  rule {
    direction   = "in"
    protocol    = "tcp"
    port        = "6443"
    source_ips  = local.all_ips
    description = "Kubernetes API server"
  }

  rule {
    direction   = "in"
    protocol    = "tcp"
    port        = "2379-2380"
    source_ips  = [var.subnet_cidr]
    description = "etcd"
  }

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
    port        = "10259"
    source_ips  = [var.subnet_cidr]
    description = "kube-scheduler"
  }

  rule {
    direction   = "in"
    protocol    = "tcp"
    port        = "10257"
    source_ips  = [var.subnet_cidr]
    description = "kube-controller-manager"
  }

  rule {
    direction   = "in"
    protocol    = "udp"
    port        = "8472"
    source_ips  = [var.subnet_cidr]
    description = "VXLAN overlay"
  }
}

resource "hcloud_server" "ctrl-001" {
  name               = "ctrl-001"
  server_type        = var.server_type
  image              = var.image
  datacenter         = var.datacenter
  placement_group_id = hcloud_placement_group.common.id

  network {
    network_id = hcloud_network.k8s_net.id
    ip         = var.ctrl-001_internal_ipv4
    alias_ips  = []
  }

  public_net {
    ipv4_enabled = false
    ipv6_enabled = true
  }

  firewall_ids = [
    hcloud_firewall.base.id,
    hcloud_firewall.ctrl.id
  ]

  ssh_keys = [
    hcloud_ssh_key.common.id
  ]

  depends_on = [
    hcloud_network_subnet.k8s_subnet
  ]
}

resource "hcloud_server" "ctrl-002" {
  name               = "ctrl-002"
  server_type        = var.server_type
  image              = var.image
  datacenter         = var.datacenter
  placement_group_id = hcloud_placement_group.common.id

  network {
    network_id = hcloud_network.k8s_net.id
    ip         = var.ctrl-002_internal_ipv4
    alias_ips  = []
  }

  public_net {
    ipv4_enabled = false
    ipv6_enabled = true
  }

  firewall_ids = [
    hcloud_firewall.base.id,
    hcloud_firewall.ctrl.id
  ]

  ssh_keys = [
    hcloud_ssh_key.common.id
  ]

  depends_on = [
    hcloud_network_subnet.k8s_subnet
  ]
}

# resource "hcloud_server" "ctrl-003" {
#   name               = "ctrl-003"
#   server_type        = var.server_type
#   image              = var.image
#   datacenter         = var.datacenter
#   placement_group_id = hcloud_placement_group.common.id
#
#   network {
#     network_id = hcloud_network.k8s_net.id
#     ip         = var.ctrl-003_internal_ipv4
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
#     hcloud_firewall.ctrl.id
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
