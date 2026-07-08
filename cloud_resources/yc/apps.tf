module "apps" {
  source = "./apps"

  cluster_host  = module.kube.external_v4_endpoint
  cluster_ca    = module.kube.cluster_ca_certificate
  cluster_sa_id = module.kube.service_account_id

  folder_id                       = var.folder_id
  zone                            = var.zone
  base_name                       = var.base_name
  cluster_id                      = module.kube.cluster_id
  email_address                   = var.email_address
  domain                          = var.domain
  argocd_admin_lockbox_secret_id  = var.argocd_admin_lockbox_secret_id
  argocd_github_lockbox_secret_id = var.argocd_github_lockbox_secret_id
  grafana_admin_lockbox_secret_id = var.grafana_admin_lockbox_secret_id
}
