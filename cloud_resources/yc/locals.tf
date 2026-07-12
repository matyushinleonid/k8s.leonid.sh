locals {
  ssh_keys = "ubuntu:${file(var.ssh_key_path)}"

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
