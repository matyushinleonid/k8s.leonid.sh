resource "yandex_vpc_address" "ingress_nginx" {
  name = "${var.base_name}-ingress-nginx"

  external_ipv4_address {
    zone_id = var.zone
  }
}

resource "yandex_logging_group" "k8s" {
  folder_id        = var.folder_id
  name             = "${var.base_name}-k8s"
  retention_period = "365h"
}

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

resource "yandex_resourcemanager_folder_iam_member" "external_secrets_lockbox_payload_viewer" {
  folder_id = var.folder_id
  role      = "lockbox.payloadViewer"
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

resource "yandex_lockbox_secret" "cert_manager" {
  folder_id = var.folder_id
  name      = "${var.base_name}-cert-manager"
}

resource "yandex_lockbox_secret_version" "cert_manager" {
  secret_id = yandex_lockbox_secret.cert_manager.id

  entries {
    key        = "authorized-key"
    text_value = local.cert_manager_sa_key_json
  }
}

resource "yandex_lockbox_secret" "external_dns" {
  folder_id = var.folder_id
  name      = "${var.base_name}-external-dns"
}

resource "yandex_lockbox_secret_version" "external_dns" {
  secret_id = yandex_lockbox_secret.external_dns.id

  entries {
    key        = "authorized-key"
    text_value = local.external_dns_sa_key_json
  }
}
