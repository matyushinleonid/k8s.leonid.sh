module "apps" {
  source = "./apps"

  cluster_host  = module.kube.external_v4_endpoint
  cluster_ca    = module.kube.cluster_ca_certificate
  cluster_sa_id = module.kube.service_account_id

  folder_id     = var.folder_id
  zone          = var.zone
  base_name     = var.base_name
  cluster_id    = module.kube.cluster_id
  email_address = var.email_address
  domain        = var.domain
}
