resource "hcloud_ssh_key" "common" {
  name       = "ssh-key"
  public_key = var.common_ssh_public_key
}

locals {
  all_ips = [
    "0.0.0.0/0",
    "::/0"
  ]
}

resource "hcloud_placement_group" "common" {
  name = "common placement group"
  type = "spread"
}

resource "hcloud_firewall" "base" {
  name = "base firewall"

  rule {
    direction   = "in"
    protocol    = "tcp"
    port        = "22"
    source_ips  = local.all_ips
    description = "Allow SSH"
  }

  rule {
    direction   = "in"
    protocol    = "icmp"
    source_ips  = local.all_ips
    description = "Allow ICMP for health checks"
  }
}
