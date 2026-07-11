output "cluster_id" {
  value = module.kube.cluster_id
}

output "cluster_name" {
  value = module.kube.cluster_name
}

output "cluster_status" {
  value = module.kube.cluster_status
}

output "cluster_external_v4_endpoint" {
  value = module.kube.external_v4_endpoint
}

output "cluster_internal_v4_endpoint" {
  value = module.kube.internal_v4_endpoint
}

output "ingress_nginx_public_ip" {
  value = module.apps.ingress_nginx_public_ip
}

output "cert_manager_service_account_key_json" {
  value     = module.apps.cert_manager_service_account_key_json
  sensitive = true
}

output "external_dns_service_account_key_json" {
  value     = module.apps.external_dns_service_account_key_json
  sensitive = true
}

output "external_secrets_service_account_key_json" {
  value     = module.apps.external_secrets_service_account_key_json
  sensitive = true
}

output "folder_id" {
  value = var.folder_id
}

output "zone" {
  value = var.zone
}

output "base_name" {
  value = var.base_name
}

output "domain" {
  value = var.domain
}

output "email_address" {
  value = var.email_address
}

output "argocd_admin_lockbox_secret_id" {
  value = var.argocd_admin_lockbox_secret_id
}

output "argocd_github_lockbox_secret_id" {
  value = var.argocd_github_lockbox_secret_id
}

output "grafana_admin_lockbox_secret_id" {
  value = var.grafana_admin_lockbox_secret_id
}
