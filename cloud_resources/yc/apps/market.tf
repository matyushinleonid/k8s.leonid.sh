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

resource "yandex_logging_group" "k8s" {
  folder_id        = var.folder_id
  name             = "${var.base_name}-k8s"
  retention_period = "365h"
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

module "addons" {
  source     = "github.com/terraform-yc-modules/terraform-yc-kubernetes-marketplace?ref=main"
  cluster_id = var.cluster_id


  install_nodelocal_dns = true
  nodelocal_dns = {
    namespace = "node-local-dns"
  }


  install_cert_manager = true
  cert_manager = {
    namespace           = "cert-manager"
    version             = "1.0.9"
    folder_id           = var.folder_id
    email_address       = var.email_address
    service_account_key = local.cert_manager_sa_key_json
    letsencrypt_server  = "https://acme-v02.api.letsencrypt.org/directory"
  }


  install_external_dns = true
  external_dns = {
    namespace           = "external-dns"
    folder_id           = var.folder_id
    service_account_key = local.external_dns_sa_key_json
  }


  install_external_secrets = true
  external_secrets = {
    namespace           = "external-secrets"
    # version             = "0.16.2"
    service_account_key = local.external_secrets_sa_key_json
  }
}

resource "kubernetes_secret_v1" "yc_lockbox_auth" {
  metadata {
    name      = "yc-lockbox-auth"
    namespace = "external-secrets"
  }

  type = "Opaque"

  data = {
    authorized-key = local.external_secrets_sa_key_json
  }

  depends_on = [
    module.addons
  ]
}

resource "kubectl_manifest" "yc_lockbox_cluster_secret_store" {
  yaml_body = yamlencode({
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ClusterSecretStore"

    metadata = {
      name = "yc-lockbox"
    }

    spec = {
      provider = {
        yandexlockbox = {
          auth = {
            authorizedKeySecretRef = {
              name      = kubernetes_secret_v1.yc_lockbox_auth.metadata[0].name
              namespace = kubernetes_secret_v1.yc_lockbox_auth.metadata[0].namespace
              key       = "authorized-key"
            }
          }
        }
      }
    }
  })

  depends_on = [
    module.addons,
    kubernetes_secret_v1.yc_lockbox_auth
  ]
}



