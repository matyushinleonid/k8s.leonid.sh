resource "yandex_compute_disk" "minecraft" {
  folder_id = var.folder_id
  zone      = var.zone
  name      = "${var.base_name}-minecraft-data"
  type      = "network-ssd"
  size      = 35

  labels = {
    managed-by = "terraform"
    persistent = "true"
    workload   = "minecraft"
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      labels["managed-kubernetes-cluster-id"]
    ]
  }
}
