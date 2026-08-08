locals {
  labels = {
    environment = "development"
    role        = "dev-vm"
  }
}

resource "hcloud_ssh_key" "dev" {
  name       = var.name
  public_key = file(pathexpand(var.ssh_public_key_path))
}

resource "hcloud_primary_ip" "dev_ipv4" {
  name        = "${var.name}-ipv4"
  location    = var.location
  type        = "ipv4"
  auto_delete = false

  labels = local.labels
}

resource "hcloud_primary_ip" "dev_ipv6" {
  name        = "${var.name}-ipv6"
  location    = var.location
  type        = "ipv6"
  auto_delete = false

  labels = local.labels
}

resource "hcloud_firewall" "dev" {
  name   = "${var.name}-firewall"
  labels = local.labels

  rule {
    direction   = "in"
    protocol    = "tcp"
    port        = "22"
    source_ips  = ["0.0.0.0/0", "::/0"]
    description = "SSH"
  }

  rule {
    direction   = "in"
    protocol    = "tcp"
    port        = tostring(var.socks5_port)
    source_ips  = var.socks5_source_ips
    description = "Authenticated SOCKS5"
  }
}

resource "hcloud_server" "dev" {
  name         = var.name
  location     = var.location
  server_type  = var.server_type
  image        = var.image
  ssh_keys     = [hcloud_ssh_key.dev.id]
  firewall_ids = [hcloud_firewall.dev.id]
  backups      = var.backups

  public_net {
    ipv4_enabled = true
    ipv4         = hcloud_primary_ip.dev_ipv4.id
    ipv6_enabled = true
    ipv6         = hcloud_primary_ip.dev_ipv6.id
  }

  labels = local.labels

  shutdown_before_deletion = true
}
