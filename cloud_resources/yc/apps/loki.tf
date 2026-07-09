resource "kubectl_manifest" "namespace_monitoring" {
  yaml_body = yamlencode({
    apiVersion = "v1"
    kind       = "Namespace"

    metadata = {
      name = "monitoring"
    }
  })
}

resource "helm_release" "loki_stack" {
  name             = "loki-stack"
  namespace        = "monitoring"
  create_namespace = false

  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki-stack"
  version    = "2.10.2"

  values = [
    yamlencode({
      loki = {
        enabled = true
        persistence = {
          enabled          = true
          storageClassName = "yc-network-hdd"
          size             = "20Gi"
        }
        config = {
          table_manager = {
            retention_deletes_enabled = true
            retention_period          = "336h"
          }
        }
      }

      promtail = {
        enabled = true
      }

      grafana = {
        enabled = false
        sidecar = {
          datasources = {
            enabled = false
          }
        }
      }
    })
  ]

  depends_on = [
    kubectl_manifest.namespace_monitoring
  ]
}
