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

resource "yandex_iam_service_account" "fluentbit" {
  folder_id = var.folder_id
  name      = "${var.base_name}-fluentbit"
}

resource "yandex_iam_service_account" "prometheus" {
  folder_id = var.folder_id
  name      = "${var.base_name}-prometheus"
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

resource "yandex_resourcemanager_folder_iam_member" "fluentbit_logging_writer" {
  folder_id = var.folder_id
  role      = "logging.writer"
  member    = "serviceAccount:${yandex_iam_service_account.fluentbit.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "prometheus_monitoring_editor" {
  folder_id = var.folder_id
  role      = "monitoring.editor"
  member    = "serviceAccount:${yandex_iam_service_account.prometheus.id}"
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

resource "yandex_iam_service_account_key" "fluentbit" {
  service_account_id = yandex_iam_service_account.fluentbit.id
}

resource "yandex_iam_service_account_key" "prometheus" {
  service_account_id = yandex_iam_service_account.prometheus.id
}

resource "yandex_logging_group" "k8s" {
  folder_id = var.folder_id
  name      = "${var.base_name}-k8s"
}

resource "yandex_vpc_address" "ingress_nginx" {
  name = "${var.base_name}-ingress-nginx"

  external_ipv4_address {
    zone_id = var.zone
  }
}

resource "yandex_iam_service_account_api_key" "prometheus" {
  service_account_id = yandex_iam_service_account.prometheus.id
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

  fluentbit_sa_key_json = sensitive(jsonencode({
    id                 = yandex_iam_service_account_key.fluentbit.id
    service_account_id = yandex_iam_service_account.fluentbit.id
    created_at         = yandex_iam_service_account_key.fluentbit.created_at
    key_algorithm      = yandex_iam_service_account_key.fluentbit.key_algorithm
    public_key         = yandex_iam_service_account_key.fluentbit.public_key
    private_key        = yandex_iam_service_account_key.fluentbit.private_key
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
    service_account_key = local.external_secrets_sa_key_json
  }


  install_ingress_nginx = true
  ingress_nginx = {
    namespace                       = "ingress-nginx"
    replica_count                   = 2
    service_loadbalancer_ip         = yandex_vpc_address.ingress_nginx.external_ipv4_address[0].address
    service_external_traffic_policy = "Cluster"
    service_session_affinity        = "None"
  }


  install_fluentbit = true
  fluentbit = {
    namespace            = "fluent-bit"
    log_group_id         = yandex_logging_group.k8s.id
    service_account_key  = local.fluentbit_sa_key_json
    export_to_s3_enabled = false
  }


  install_prometheus = true
  prometheus = {
    namespace               = "prometheus"
    prometheus_workspace_id = var.prometheus_workspace_id
    api_key_value           = yandex_iam_service_account_api_key.prometheus.secret_key
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



