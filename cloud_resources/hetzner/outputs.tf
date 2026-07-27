output "server_id" {
  description = "Hetzner Cloud server ID."
  value       = hcloud_server.amnezia.id
}

output "server_ipv4" {
  description = "Public IPv4 address used by AmneziaVPN."
  value       = hcloud_server.amnezia.ipv4_address
}

output "server_ipv6" {
  description = "Public IPv6 address assigned to the server."
  value       = hcloud_server.amnezia.ipv6_address
}

output "server_ipv6_network" {
  description = "Public IPv6 /64 network allocated to the server."
  value       = hcloud_primary_ip.ipv6.ip_address
}

output "ssh_command" {
  description = "Command for connecting to the server."
  value       = "ssh -i ${trimsuffix(pathexpand(var.ssh_public_key_path), ".pub")} root@${hcloud_server.amnezia.ipv4_address}"
}
