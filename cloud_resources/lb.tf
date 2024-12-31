resource "hcloud_firewall" "load_balancer" {
  name = "load balancer firewall"

  rule {
    direction   = "in"
    protocol    = "tcp"
    port        = "80"
    source_ips  = local.all_ips
    description = "Allow HTTP"
  }
}

resource "hcloud_server" "lb-001" {
  name               = "lb-001"
  server_type        = var.server_type
  image              = var.image
  datacenter         = var.datacenter
  placement_group_id = hcloud_placement_group.common.id

  network {
    network_id = hcloud_network.k8s_net.id
    ip         = var.lb-001_internal_ipv4
    alias_ips = []
  }

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }

  firewall_ids = [
    hcloud_firewall.base.id,
    hcloud_firewall.load_balancer.id
  ]

  ssh_keys = [
    hcloud_ssh_key.common.id
  ]

  depends_on = [
    hcloud_network_subnet.k8s_subnet
  ]
}
