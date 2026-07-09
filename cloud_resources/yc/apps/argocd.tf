resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  version          = "9.7.1"
  create_namespace = true

  values = [
    yamlencode({
      global = {
        domain = "argocd.${var.domain}"
      }

      configs = {
        params = {
          "server.insecure" = true
        }
      }

      server = {
        extraArgs = ["--insecure"]

        ingress = {
          enabled          = true
          ingressClassName = "nginx"

          annotations = {
            "cert-manager.io/cluster-issuer"                 = "yc-clusterissuer"
            "nginx.ingress.kubernetes.io/force-ssl-redirect" = "true"
            "nginx.ingress.kubernetes.io/backend-protocol"   = "HTTP"
          }

          hosts = ["argocd.${var.domain}"]

          tls = [
            {
              secretName = "argocd-server-tls"
              hosts      = ["argocd.${var.domain}"]
            }
          ]
        }
      }
    })
  ]
}

resource "kubectl_manifest" "argocd_admin_secret" {
  yaml_body = yamlencode({
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ExternalSecret"

    metadata = {
      name      = "argocd-admin-secret"
      namespace = "argocd"
    }

    spec = {
      refreshInterval = "1h"

      secretStoreRef = {
        name = "yc-lockbox"
        kind = "ClusterSecretStore"
      }

      target = {
        name           = "argocd-secret"
        creationPolicy = "Merge"

        template = {
          type = "Opaque"

          data = {
            "admin.password"      = "{{ .admin_password_hash }}"
            "admin.passwordMtime" = "2025-01-01T00:00:00Z"
          }
        }
      }

      data = [
        {
          secretKey = "admin_password_hash"

          remoteRef = {
            key      = var.argocd_admin_lockbox_secret_id
            property = "admin-password-hash"
          }
        }
      ]
    }
  })

  depends_on = [
    module.addons,
    kubernetes_secret_v1.yc_lockbox_auth,
    kubectl_manifest.yc_lockbox_cluster_secret_store,
    helm_release.argocd
  ]
}

resource "kubectl_manifest" "argocd_github_repo_creds" {
  yaml_body = yamlencode({
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ExternalSecret"

    metadata = {
      name      = "argocd-github-repo-creds"
      namespace = "argocd"
    }

    spec = {
      refreshInterval = "1h"

      secretStoreRef = {
        name = "yc-lockbox"
        kind = "ClusterSecretStore"
      }

      target = {
        name           = "argocd-github-repo-creds"
        creationPolicy = "Owner"

        template = {
          type = "Opaque"

          metadata = {
            labels = {
              "argocd.argoproj.io/secret-type" = "repo-creds"
            }
          }

          data = {
            type          = "git"
            url           = "git@github.com:matyushinleonid"
            sshPrivateKey = "{{ .github_ssh_key }}"
          }
        }
      }

      data = [
        {
          secretKey = "github_ssh_key"

          remoteRef = {
            key      = var.argocd_github_lockbox_secret_id
            property = "github-ssh-key"
          }
        }
      ]
    }
  })

  depends_on = [
    module.addons,
    kubernetes_secret_v1.yc_lockbox_auth,
    kubectl_manifest.yc_lockbox_cluster_secret_store,
    helm_release.argocd
  ]
}

resource "kubectl_manifest" "mothership_app" {
  yaml_body = yamlencode({
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"

    metadata = {
      name      = "mothership"
      namespace = "argocd"
    }

    spec = {
      project = "default"

      source = {
        repoURL        = "git@github.com:matyushinleonid/k8s.leonid.sh.git"
        targetRevision = "HEAD"
        path           = "argocd"

        directory = {
          recurse = true
          include = "**/argoapp.yaml"
        }
      }

      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "argocd"
      }
    }
  })

  depends_on = [
    helm_release.argocd,
    kubectl_manifest.argocd_github_repo_creds
  ]
}
