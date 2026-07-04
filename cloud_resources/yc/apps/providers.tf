terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.17.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.19"
    }
  }
}

data "yandex_client_config" "client" {}

provider "kubernetes" {
  host                   = var.cluster_host
  cluster_ca_certificate = var.cluster_ca
  token                  = data.yandex_client_config.client.iam_token
}

provider "helm" {
  kubernetes {
    host                   = var.cluster_host
    cluster_ca_certificate = var.cluster_ca
    token                  = data.yandex_client_config.client.iam_token
  }
}

provider "kubectl" {
  host                   = var.cluster_host
  cluster_ca_certificate = var.cluster_ca
  token                  = data.yandex_client_config.client.iam_token
  load_config_file       = false
}
