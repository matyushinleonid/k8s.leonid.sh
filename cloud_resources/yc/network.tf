resource "yandex_vpc_network" "k8s_network" {
  name = var.base_name
}

resource "yandex_vpc_subnet" "k8s_subnet" {
  name           = var.base_name
  network_id     = yandex_vpc_network.k8s_network.id
  v4_cidr_blocks = var.subnet_cidr
}
