output "server_id" {
  value = hcloud_server.dev.id
}

output "server_ipv4" {
  value = hcloud_server.dev.ipv4_address
}

output "server_ipv6" {
  value = hcloud_server.dev.ipv6_address
}

output "server_ipv6_network" {
  value = hcloud_primary_ip.dev_ipv6.ip_address
}

output "socks5_port" {
  value = var.socks5_port
}
