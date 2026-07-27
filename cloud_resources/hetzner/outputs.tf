output "server_id" {
  value = hcloud_server.amnezia.id
}

output "server_ipv4" {
  value = hcloud_server.amnezia.ipv4_address
}

output "server_ipv6" {
  value = hcloud_server.amnezia.ipv6_address
}

output "server_ipv6_network" {
  value = hcloud_primary_ip.ipv6.ip_address
}
