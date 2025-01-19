output "lb-001_ipv6" {
  value = hcloud_server.lb-001.ipv6_address
}

output "lb-001_ipv4" {
  value = hcloud_server.lb-001.ipv4_address
}

output "lb-001_internal_ipv4" {
  value = var.lb-001_internal_ipv4
}

output "ctrl-001_ipv6" {
  value = hcloud_server.ctrl-001.ipv6_address
}

output "ctrl-001_internal_ipv4" {
  value = var.ctrl-001_internal_ipv4
}

output "ctrl-002_ipv6" {
  value = hcloud_server.ctrl-002.ipv6_address
}

output "ctrl-002_internal_ipv4" {
  value = var.ctrl-002_internal_ipv4
}

output "ctrl-003_ipv6" {
  value = hcloud_server.ctrl-003.ipv6_address
}

output "ctrl-003_internal_ipv4" {
  value = var.ctrl-003_internal_ipv4
}

output "worker-001_ipv6" {
  value = hcloud_server.worker-001.ipv6_address
}

output "worker-001_internal_ipv4" {
  value = var.worker-001_internal_ipv4
}

output "worker-002_ipv6" {
  value = hcloud_server.worker-002.ipv6_address
}

output "worker-002_internal_ipv4" {
  value = var.worker-002_internal_ipv4
}
