resource "yandex_vpc_network" "k8s_network" {
  name      = var.network_name
  folder_id = var.folder_id
}

resource "yandex_vpc_subnet" "k8s_subnet" {
  name           = var.subnet_name
  folder_id      = var.folder_id
  zone           = var.zone
  network_id     = yandex_vpc_network.k8s_network.id
  v4_cidr_blocks = var.subnet_cidr
}
