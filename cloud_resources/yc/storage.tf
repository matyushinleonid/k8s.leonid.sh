resource "yandex_compute_disk" "minecraft" {
  folder_id = var.folder_id
  zone      = var.zone
  name      = "${var.base_name}-minecraft-data"
  type      = "network-ssd"
  size      = 10

  labels = {
    managed-by = "terraform"
    persistent = "true"
    workload   = "minecraft"
  }

  lifecycle {
    prevent_destroy = true
  }
}
