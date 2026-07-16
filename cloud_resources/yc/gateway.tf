resource "yandex_vpc_address" "gateway" {
  name = "${var.base_name}-gateway"

  external_ipv4_address {
    zone_id = var.zone
  }
}
