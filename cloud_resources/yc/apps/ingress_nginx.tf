resource "yandex_vpc_address" "ingress_nginx" {
  name = "${var.base_name}-ingress-nginx"

  external_ipv4_address {
    zone_id = var.zone
  }
}
