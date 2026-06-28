terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.17.0"
    }
  }
}

data "yandex_client_config" "client" {}

provider "helm" {
  kubernetes {
    host                   = var.cluster_host
    cluster_ca_certificate = var.cluster_ca
    token                  = data.yandex_client_config.client.iam_token
  }
}