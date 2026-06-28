resource "yandex_iam_service_account" "cert_manager" {
  folder_id = var.folder_id
  name      = "${var.base_name}-cert-manager"
}

resource "yandex_iam_service_account" "external_dns" {
  folder_id = var.folder_id
  name      = "${var.base_name}-external-dns"
}

resource "yandex_iam_service_account" "external_secrets" {
  folder_id = var.folder_id
  name      = "${var.base_name}-external-secrets"
}


resource "yandex_resourcemanager_folder_iam_member" "cert_manager_dns_editor" {
  folder_id = var.folder_id
  role      = "dns.editor"
  member    = "serviceAccount:${yandex_iam_service_account.cert_manager.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "external_dns_editor" {
  folder_id = var.folder_id
  role      = "dns.editor"
  member    = "serviceAccount:${yandex_iam_service_account.external_dns.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "external_secrets_lockbox_editor" {
  folder_id = var.folder_id
  role      = "lockbox.editor"
  member    = "serviceAccount:${yandex_iam_service_account.external_secrets.id}"
}


resource "yandex_iam_service_account_key" "cert_manager" {
  service_account_id = yandex_iam_service_account.cert_manager.id
}

resource "yandex_iam_service_account_key" "external_dns" {
  service_account_id = yandex_iam_service_account.external_dns.id
}

resource "yandex_iam_service_account_key" "external_secrets" {
  service_account_id = yandex_iam_service_account.external_secrets.id
}


locals {
  cert_manager_sa_key_json = sensitive(jsonencode({
    id                 = yandex_iam_service_account_key.cert_manager.id
    service_account_id = yandex_iam_service_account.cert_manager.id
    created_at         = yandex_iam_service_account_key.cert_manager.created_at
    key_algorithm      = yandex_iam_service_account_key.cert_manager.key_algorithm
    public_key         = yandex_iam_service_account_key.cert_manager.public_key
    private_key        = yandex_iam_service_account_key.cert_manager.private_key
  }))

  external_dns_sa_key_json = sensitive(jsonencode({
    id                 = yandex_iam_service_account_key.external_dns.id
    service_account_id = yandex_iam_service_account.external_dns.id
    created_at         = yandex_iam_service_account_key.external_dns.created_at
    key_algorithm      = yandex_iam_service_account_key.external_dns.key_algorithm
    public_key         = yandex_iam_service_account_key.external_dns.public_key
    private_key        = yandex_iam_service_account_key.external_dns.private_key
  }))

  external_secrets_sa_key_json = sensitive(jsonencode({
    id                 = yandex_iam_service_account_key.external_secrets.id
    service_account_id = yandex_iam_service_account.external_secrets.id
    created_at         = yandex_iam_service_account_key.external_secrets.created_at
    key_algorithm      = yandex_iam_service_account_key.external_secrets.key_algorithm
    public_key         = yandex_iam_service_account_key.external_secrets.public_key
    private_key        = yandex_iam_service_account_key.external_secrets.private_key
  }))
}


resource "yandex_vpc_address" "ingress_nginx" {
  name = "${var.base_name}-ingress-nginx"

  external_ipv4_address {
    zone_id = var.zone
  }
}


module "addons" {
  source = "github.com/matyushinleonid/terraform-yc-kubernetes-marketplace?ref=matyushinleonid-patch-1"

  cluster_id = var.cluster_id

  ##########################################
  # NodeLocal DNS
  ##########################################

  install_nodelocal_dns = true

  nodelocal_dns = {
    namespace = "node-local-dns"
  }

  ##########################################
  # cert-manager with Yandex Cloud DNS webhook
  ##########################################

  install_cert_manager = true

  cert_manager = {
    namespace           = "cert-manager"
    folder_id           = var.folder_id
    email_address       = var.email_address
    service_account_key = local.cert_manager_sa_key_json

    letsencrypt_server = "https://acme-v02.api.letsencrypt.org/directory"
  }

  ##########################################
  # ExternalDNS for Yandex Cloud DNS
  ##########################################

  install_external_dns = true

  external_dns = {
    namespace           = "external-dns"
    folder_id           = var.folder_id
    service_account_key = local.external_dns_sa_key_json
  }

  ##########################################
  # External Secrets Operator with Yandex Lockbox
  ##########################################

  install_external_secrets = true

  external_secrets = {
    namespace           = "external-secrets"
    service_account_key = local.external_secrets_sa_key_json
  }

  ##########################################
  # Ingress NGINX
  ##########################################

  install_ingress_nginx = true

  ingress_nginx = {
    namespace                       = "ingress-nginx"
    ingress_class_name              = "nginx"
    replica_count                   = 2
    service_loadbalancer_ip         = yandex_vpc_address.ingress_nginx.external_ipv4_address[0].address
    service_external_traffic_policy = "Local"
    service_session_affinity        = "None"
  }
}
