resource "helm_release" "kube_prometheus_stack" {
  name             = "kube-prometheus-stack"
  namespace        = "monitoring"
  create_namespace = true

  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "87.10.0"

  values = [
    yamlencode({
      prometheus = {
        prometheusSpec = {
          retention = "14d"

          storageSpec = {
            volumeClaimTemplate = {
              spec = {
                storageClassName = "yc-network-ssd"
                accessModes      = ["ReadWriteOnce"]

                resources = {
                  requests = {
                    storage = "20Gi"
                  }
                }
              }
            }
          }
        }
      }

      grafana = {
        enabled = true

        admin = {
          existingSecret = "grafana-admin-credentials"
          userKey        = "admin-user"
          passwordKey    = "admin-password"
        }

        additionalDataSources = [
          {
            name      = "Loki"
            type      = "loki"
            url       = "http://loki-stack:3100" # check
            access    = "proxy"
            isDefault = false
          }
        ]

        ingress = {
          enabled          = true
          ingressClassName = "nginx"

          annotations = {
            "cert-manager.io/cluster-issuer" = "yc-clusterissuer"
          }

          hosts = [
            "grafana.${var.domain}"
          ]

          path     = "/"
          pathType = "Prefix"

          tls = [
            {
              secretName = "grafana-tls"
              hosts = [
                "grafana.${var.domain}"
              ]
            }
          ]
        }
      }
    })
  ]

  depends_on = [
    helm_release.loki_stack,
    kubectl_manifest.grafana_admin_secret
  ]
}

resource "kubectl_manifest" "grafana_admin_secret" {
  yaml_body = yamlencode({
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ExternalSecret"

    metadata = {
      name      = "grafana-admin"
      namespace = "monitoring"
    }

    spec = {
      refreshInterval = "1h"

      secretStoreRef = {
        name = "yc-lockbox"
        kind = "ClusterSecretStore"
      }

      target = {
        name           = "grafana-admin-credentials"
        creationPolicy = "Owner"

        template = {
          type = "Opaque"

          data = {
            "admin-user"     = "{{ .grafana_admin_user }}"
            "admin-password" = "{{ .grafana_admin_password }}"
          }
        }
      }

      data = [
        {
          secretKey = "grafana_admin_user"
          remoteRef = {
            key      = var.grafana_admin_lockbox_secret_id
            property = "grafana-admin-user"
          }
        },
        {
          secretKey = "grafana_admin_password"
          remoteRef = {
            key      = var.grafana_admin_lockbox_secret_id
            property = "grafana-admin-password"
          }
        }
      ]
    }
  })

  depends_on = [
    kubectl_manifest.yc_lockbox_cluster_secret_store,
    helm_release.loki_stack
  ]
}
