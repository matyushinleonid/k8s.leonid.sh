output "ingress_nginx_public_ip" {
  value = yandex_vpc_address.ingress_nginx.external_ipv4_address[0].address
}