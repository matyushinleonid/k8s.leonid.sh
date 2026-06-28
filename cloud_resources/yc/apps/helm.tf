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
        domain = "argocd.leonid.sh"
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

          hosts = ["argocd.leonid.sh"]

          tls = [
            {
              secretName = "argocd-server-tls"
              hosts      = ["argocd.leonid.sh"]
            }
          ]
        }
      }
    })
  ]
}
