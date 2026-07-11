module "apps" {
  source = "./apps"

  folder_id                       = var.folder_id
  zone                            = var.zone
  base_name                       = var.base_name
  email_address                   = var.email_address
  domain                          = var.domain
  argocd_admin_lockbox_secret_id  = var.argocd_admin_lockbox_secret_id
  argocd_github_lockbox_secret_id = var.argocd_github_lockbox_secret_id
  grafana_admin_lockbox_secret_id = var.grafana_admin_lockbox_secret_id
}
