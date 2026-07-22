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

resource "yandex_iam_service_account" "github_ci" {
  folder_id = var.folder_id
  name      = "${var.base_name}-github-ci"
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

resource "yandex_iam_service_account_key" "github_ci" {
  service_account_id = yandex_iam_service_account.github_ci.id
}
