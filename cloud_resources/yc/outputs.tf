output "cluster_id" {
  description = "required for ansible bootstrap"
  value       = module.kube.cluster_id
}

output "external_secrets_service_account_key_json" {
  description = "required for ansible bootstrap"
  value       = local.external_secrets_sa_key_json
  sensitive   = true
}

output "argocd_github_lockbox_secret_id" {
  description = "required for ansible bootstrap"
  value       = var.argocd_github_lockbox_secret_id
}

output "gateway_public_ip" {
  description = "Shared public IP for HTTP, HTTPS, TCP traffic; set manually in argocd/platform/envoy-gateway/values.yaml."
  value       = yandex_vpc_address.gateway.external_ipv4_address[0].address
}

output "cert_manager_lockbox_secret_id" {
  description = "set manually in argocd/platform/cert-manager/values.yaml."
  value       = yandex_lockbox_secret.cert_manager.id
}

output "external_dns_lockbox_secret_id" {
  description = "set manually in argocd/platform/external-dns/values.yaml."
  value       = yandex_lockbox_secret.external_dns.id
}
