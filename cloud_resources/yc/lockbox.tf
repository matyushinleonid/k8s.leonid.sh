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

data "yandex_lockbox_secret_version_entry" "temporal_pg_password" {
  secret_id = "e6qojcm2ke05j3v745t1"
  key       = "temporal_postgres_password"
}
