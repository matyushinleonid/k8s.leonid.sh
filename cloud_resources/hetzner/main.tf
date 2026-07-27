resource "hcloud_ssh_key" "amnezia" {
  name       = var.name
  public_key = file(pathexpand(var.ssh_public_key_path))
}

resource "hcloud_primary_ip" "ipv4" {
  name        = "${var.name}-ipv4"
  location    = var.location
  type        = "ipv4"
  auto_delete = false

  labels = {
    service = "amnezia"
  }
}

resource "hcloud_primary_ip" "ipv6" {
  name        = "${var.name}-ipv6"
  location    = var.location
  type        = "ipv6"
  auto_delete = false

  labels = {
    service = "amnezia"
  }
}

resource "hcloud_server" "amnezia" {
  name        = var.name
  location    = var.location
  server_type = var.server_type
  image       = var.image
  ssh_keys    = [hcloud_ssh_key.amnezia.id]
  backups     = var.backups

  public_net {
    ipv4_enabled = true
    ipv4         = hcloud_primary_ip.ipv4.id
    ipv6_enabled = true
    ipv6         = hcloud_primary_ip.ipv6.id
  }

  labels = {
    service = "amnezia"
  }

  shutdown_before_deletion = true
}
