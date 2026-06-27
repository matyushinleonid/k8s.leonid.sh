resource "yandex_kubernetes_node_group" "k8s_node_group" {
  name = var.node_group_name

  cluster_id = yandex_kubernetes_cluster.k8s_cluster.id
  version    = var.kubernetes_version

  instance_template {
    platform_id = var.node_platform_id

    network_interface {
      nat                = var.enable_public_ip_for_nodes
      subnet_ids         = [yandex_vpc_subnet.k8s_subnet.id]
      security_group_ids = [yandex_vpc_security_group.k8s_sg.id]
    }

    resources {
      cores         = var.node_cores
      memory        = var.node_memory
      core_fraction = var.node_core_fraction
    }

    boot_disk {
      type = var.node_disk_type
      size = var.node_disk_size
    }

    scheduling_policy {
      preemptible = false
    }

    container_runtime {
      type = "containerd"
    }

    metadata = {
      ssh-keys = "ubuntu:${file("~/.ssh/k8s.leonid.sh.pub")}"
    }
  }

  scale_policy {
    fixed_scale {
      size = var.node_count
    }
  }

  allocation_policy {
    location {
      zone = var.zone
    }
  }

  maintenance_policy {
    auto_upgrade = true
    auto_repair  = true

    maintenance_window {
      start_time = "04:00"
      duration   = "3h"
    }
  }

  depends_on = [
    yandex_kubernetes_cluster.k8s_cluster
  ]
}
