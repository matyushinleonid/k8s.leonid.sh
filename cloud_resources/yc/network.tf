resource "yandex_vpc_network" "k8s_network" {
  name = var.base_name
}

resource "yandex_vpc_subnet" "k8s_subnet" {
  name           = var.base_name
  network_id     = yandex_vpc_network.k8s_network.id
  v4_cidr_blocks = var.subnet_cidr

  route_table_id = yandex_vpc_route_table.nat_route_table.id
}

resource "yandex_vpc_gateway" "nat_gateway" {
  name = "${var.base_name}-nat-gateway"

  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "nat_route_table" {
  name       = "${var.base_name}-nat-route-table"
  network_id = yandex_vpc_network.k8s_network.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gateway.id
  }
}

resource "yandex_dns_zone" "local_dns" {
  name             = "pg-internal-zone"
  zone             = "local."
  public           = false
  private_networks = [yandex_vpc_network.k8s_network.id]
}
