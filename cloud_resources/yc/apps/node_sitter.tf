resource "helm_release" "node_sitter" {
  name             = "node-sitter"
  namespace        = "node-sitter"
  create_namespace = true

  repository = "oci://cr.yandex/yc-marketplace/yandex-cloud/node-sitter/node-sitter/chart"
  chart      = "node-sitter"
  version    = "0.1.6"

  set {
    name  = "node_drainer_enabled"
    value = "true"
  }

  set {
    name  = "toleration_name"
    value = "preemptible"
  }
}

