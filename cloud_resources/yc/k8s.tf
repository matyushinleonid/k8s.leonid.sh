resource "yandex_kubernetes_cluster" "k8s_cluster" {
  name = var.cluster_name

  folder_id  = var.folder_id
  network_id = yandex_vpc_network.k8s_network.id

  service_account_id      = yandex_iam_service_account.k8s_sa.id
  node_service_account_id = yandex_iam_service_account.k8s_sa.id

  release_channel = var.release_channel

  dynamic "master" {
    for_each = [1]

    content {
      version = var.kubernetes_version

      public_ip = var.enable_public_ip_for_master

      master_location {
        zone      = yandex_vpc_subnet.k8s_subnet.zone
        subnet_id = yandex_vpc_subnet.k8s_subnet.id
      }

      security_group_ids = [
        yandex_vpc_security_group.k8s_sg.id
      ]

      maintenance_policy {
        auto_upgrade = true

        maintenance_window {
          start_time = "03:00"
          duration   = "3h"
        }
      }
    }
  }

  kms_provider {
    key_id = yandex_kms_symmetric_key.k8s_kms_key.id
  }

  depends_on = [
    yandex_resourcemanager_folder_iam_member.k8s_clusters_agent,
    yandex_resourcemanager_folder_iam_member.vpc_public_admin,
    yandex_resourcemanager_folder_iam_member.container_registry_images_puller,
    yandex_resourcemanager_folder_iam_member.kms_encrypter_decrypter
  ]
}
