resource "hcloud_network" "k8s_net" {
  name     = "k8s-net"
  ip_range = var.network_cidr
}

resource "hcloud_network_subnet" "k8s_subnet" {
  network_id   = hcloud_network.k8s_net.id
  type         = "cloud"
  network_zone = var.zone
  ip_range     = var.subnet_cidr
}
