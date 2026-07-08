resource "yandex_vpc_address" "ingress_nginx" {
  name = "${var.base_name}-ingress-nginx"

  external_ipv4_address {
    zone_id = var.zone
  }
}

resource "helm_release" "ingress_nginx" {
  name             = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true

  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.15.1"

  values = [
    yamlencode({
      controller = {
        ingressClassResource = {
          name = "nginx"
        }

        replicaCount = 2

        service = {
          loadBalancerIP        = yandex_vpc_address.ingress_nginx.external_ipv4_address[0].address
          externalTrafficPolicy = "Cluster"
          sessionAffinity       = "None"
        }
      }
    })
  ]
}

