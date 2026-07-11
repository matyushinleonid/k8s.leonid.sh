output "ingress_nginx_public_ip" {
  value = yandex_vpc_address.ingress_nginx.external_ipv4_address[0].address
}

output "k8s_logging_group_id" {
  value = yandex_logging_group.k8s.id
}

output "cert_manager_service_account_key_json" {
  value     = local.cert_manager_sa_key_json
  sensitive = true
}

output "external_dns_service_account_key_json" {
  value     = local.external_dns_sa_key_json
  sensitive = true
}

output "external_secrets_service_account_key_json" {
  value     = local.external_secrets_sa_key_json
  sensitive = true
}
